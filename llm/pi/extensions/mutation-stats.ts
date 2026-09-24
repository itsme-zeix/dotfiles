import { readFile } from "node:fs/promises";
import path from "node:path";
import {
	createEditToolDefinition,
	createWriteToolDefinition,
	generateDiffString,
	type ExtensionAPI,
	type Theme,
} from "@earendil-works/pi-coding-agent";
import { truncateToWidth, visibleWidth, type Component } from "@earendil-works/pi-tui";

type LineStats = {
	added: number;
	removed: number;
};

type StatsState = {
	stats?: LineStats;
	wrappedCall?: Component;
	innerCall?: Component;
};

function countDiff(diff: string): LineStats {
	let added = 0;
	let removed = 0;
	for (const line of diff.split("\n")) {
		if (line.startsWith("+")) added++;
		else if (line.startsWith("-")) removed++;
	}
	return { added, removed };
}

function formatStats(stats: LineStats, theme: Theme): string {
	return ` (${theme.fg("success", `+${stats.added}`)} ${theme.fg("error", `-${stats.removed}`)})`;
}

function appendToFirstLine(
	inner: Component,
	suffix: () => string | undefined,
	fill: ((width: number) => string) | undefined = undefined,
): Component {
	return {
		invalidate: () => inner.invalidate(),
		render(width: number): string[] {
			const renderedSuffix = suffix();
			if (!renderedSuffix) return inner.render(width);

			const suffixWidth = visibleWidth(renderedSuffix);
			const lines = inner.render(Math.max(1, width - suffixWidth));
			const contentLine = lines.findIndex((line) =>
				line
					.replace(/\x1b\][^\x07]*(?:\x07|\x1b\\)/g, "")
					.replace(/\x1b\[[0-9;]*m/g, "")
					.trim(),
			);
			// Pi components may return cached render arrays, so never modify their rows in place.
			return lines.map((line, index) => {
				const appended = line + (index === Math.max(0, contentLine) ? renderedSuffix : fill?.(suffixWidth) ?? "");
				return visibleWidth(appended) > width ? truncateToWidth(appended, width, "") : appended;
			});
		},
	};
}

function resolveFile(cwd: string, file: string): string {
	return path.isAbsolute(file) ? file : path.resolve(cwd, file);
}

export default function mutationStats(pi: ExtensionAPI): void {
	const cwd = process.cwd();
	const edit = createEditToolDefinition(cwd);
	const write = createWriteToolDefinition(cwd);
	const pendingEditStats = new Map<string, LineStats>();
	const pendingWriteStats = new Map<string, LineStats>();

	pi.registerTool({
		...edit,
		async execute(toolCallId, params, signal, onUpdate, ctx) {
			const result = await edit.execute(toolCallId, params, signal, onUpdate, ctx);
			if (result.details?.diff) pendingEditStats.set(toolCallId, countDiff(result.details.diff));
			return result;
		},
		renderCall(args, theme, context) {
			const state = context.state as typeof context.state & StatsState;
			state.stats ??= pendingEditStats.get(context.toolCallId);
			if (state.stats) pendingEditStats.delete(context.toolCallId);

			const inner = edit.renderCall?.(args, theme, { ...context, lastComponent: state.innerCall });
			if (!inner) return undefined;
			if (state.innerCall !== inner || !state.wrappedCall) {
				state.innerCall = inner;
				state.wrappedCall = appendToFirstLine(
					inner,
					() => state.stats && theme.bg("toolSuccessBg", formatStats(state.stats, theme)),
					(width) => theme.bg("toolSuccessBg", " ".repeat(width)),
				);
			}
			return state.wrappedCall;
		},
	});

	pi.registerTool({
		...write,
		async execute(toolCallId, params, signal, onUpdate, ctx) {
			let previous: string | undefined;
			try {
				previous = await readFile(resolveFile(cwd, params.path), "utf8");
			} catch (error) {
				if (error instanceof Error && "code" in error && error.code === "ENOENT") previous = "";
			}

			const result = await write.execute(toolCallId, params, signal, onUpdate, ctx);
			if (previous !== undefined) {
				pendingWriteStats.set(toolCallId, countDiff(generateDiffString(previous, params.content).diff));
			}
			return result;
		},
		renderCall(args, theme, context) {
			const state = context.state as typeof context.state & StatsState;
			state.stats ??= pendingWriteStats.get(context.toolCallId);
			if (state.stats) pendingWriteStats.delete(context.toolCallId);

			const inner = write.renderCall?.(args, theme, { ...context, lastComponent: state.innerCall });
			if (!inner) return undefined;
			if (state.innerCall !== inner || !state.wrappedCall) {
				state.innerCall = inner;
				state.wrappedCall = appendToFirstLine(inner, () => state.stats && formatStats(state.stats, theme));
			}
			return state.wrappedCall;
		},
	});
}
