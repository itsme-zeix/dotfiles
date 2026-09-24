import type { ExtensionAPI, ExtensionContext, Theme } from "@earendil-works/pi-coding-agent";
import { getLanguageFromPath, highlightCode } from "@earendil-works/pi-coding-agent";
import { truncateToWidth, visibleWidth, wrapTextWithAnsi } from "@earendil-works/pi-tui";

const DIFF_ENTRY = "workflow-diff";
const GOAL_ENTRY = "workflow-goal";
const MAX_GOAL_LENGTH = 4_000;
const MAX_HIGHLIGHT_BYTES = 512 * 1024;
const MAX_HIGHLIGHT_LINES = 10_000;
const MAX_HIGHLIGHT_LINE_BYTES = 4 * 1024;

type GoalState = {
	objective: string;
	status: "active" | "paused";
};

type DiffData = {
	diff: string;
};

type DiffFile = {
	path: string;
	hunks: DiffHunk[];
	added: number;
	removed: number;
	kind: "added" | "deleted" | "edited";
};

type DiffHunk = {
	lines: DiffLine[];
};

type DiffLine = {
	marker: "+" | "-" | " ";
	source: string;
	oldLine?: number;
	newLine?: number;
};

function diffDestination(line: string): string {
	const body = line.slice("diff --git ".length);
	const quoted = body.match(/^("(?:\\.|[^"\\])*") ("(?:\\.|[^"\\])*")$/);
	if (quoted) {
		try {
			return (JSON.parse(quoted[2]) as string).replace(/^b\//, "");
		} catch {}
	}

	const separator = body.lastIndexOf(" b/");
	return separator === -1 ? "unknown" : body.slice(separator + 3);
}

function parseDiff(diff: string): DiffFile[] {
	const files: DiffFile[] = [];
	let current: DiffFile | undefined;
	let hunk: DiffHunk | undefined;
	let oldLine = 0;
	let newLine = 0;

	for (const line of diff.split("\n")) {
		if (line.startsWith("diff --git ")) {
			if (current) files.push(current);
			current = { path: diffDestination(line), hunks: [], added: 0, removed: 0, kind: "edited" };
			hunk = undefined;
			continue;
		}
		if (!current) continue;
		if (line === "--- /dev/null") current.kind = "added";
		if (line === "+++ /dev/null") current.kind = "deleted";

		const header = line.match(/^@@ -(\d+)(?:,\d+)? \+(\d+)(?:,\d+)? @@/);
		if (header) {
			oldLine = Number(header[1]);
			newLine = Number(header[2]);
			hunk = { lines: [] };
			current.hunks.push(hunk);
			continue;
		}
		if (!hunk || line.startsWith("\\ No newline")) continue;

		const marker = line[0];
		if (marker === "+") {
			hunk.lines.push({ marker, source: line.slice(1), newLine: newLine++ });
			current.added++;
		} else if (marker === "-") {
			hunk.lines.push({ marker, source: line.slice(1), oldLine: oldLine++ });
			current.removed++;
		} else if (marker === " ") {
			hunk.lines.push({ marker, source: line.slice(1), oldLine: oldLine++, newLine: newLine++ });
		}
	}

	if (current) files.push(current);
	return files;
}

function paintBackground(text: string, width: number, rgb: [number, number, number]): string {
	const fitted = truncateToWidth(text, width, "", true);
	const padding = " ".repeat(Math.max(0, width - visibleWidth(fitted)));
	return `\x1b[48;2;${rgb.join(";")}m${fitted}${padding}\x1b[49m`;
}

function lineNumber(value: number | undefined, width: number, theme: Theme): string {
	return theme.fg("dim", value === undefined ? " ".repeat(width) : String(value).padStart(width));
}

function countSummary(added: number, removed: number, theme: Theme): string {
	return `(${theme.fg("success", `+${added}`)} ${theme.fg("error", `-${removed}`)})`;
}

class DiffComponent {
	constructor(
		private readonly data: DiffData,
		private readonly theme: Theme,
	) {}

	invalidate(): void {}

	render(width: number): string[] {
		const files = parseDiff(this.data.diff);
		const rendered: string[] = [];
		const totalAdded = files.reduce((sum, file) => sum + file.added, 0);
		const totalRemoved = files.reduce((sum, file) => sum + file.removed, 0);
		const heading = files.length === 1
			? `${this.theme.fg("dim", "•")} ${this.theme.bold(files[0].kind[0].toUpperCase() + files[0].kind.slice(1))} ${this.theme.fg("text", files[0].path)} ${countSummary(files[0].added, files[0].removed, this.theme)}`
			: `${this.theme.fg("dim", "•")} ${this.theme.bold("Edited")} ${files.length} files ${countSummary(totalAdded, totalRemoved, this.theme)}`;
		rendered.push(truncateToWidth(heading, width, "..."));

		for (const [fileIndex, file] of files.entries()) {
			if (files.length > 1) {
				if (fileIndex > 0) rendered.push("");
				rendered.push(
					truncateToWidth(
						`${this.theme.fg("dim", "  └")} ${this.theme.fg("text", file.path)} ${countSummary(file.added, file.removed, this.theme)}`,
						width,
						"...",
					),
				);
			}

			const maxLine = file.hunks
				.flatMap((item) => item.lines)
				.reduce((max, line) => Math.max(max, line.oldLine ?? 0, line.newLine ?? 0), 0);
			const numberWidth = Math.max(1, String(maxLine).length);
			const indent = "    ";
			const contentWidth = Math.max(1, width - visibleWidth(indent) - numberWidth - 2);
			const language = getLanguageFromPath(file.path);
			const sourceLines = file.hunks.flatMap((item) => item.lines.map((line) => line.source));
			const sourceBytes = sourceLines.reduce((sum, line) => sum + Buffer.byteLength(line), 0);
			const shouldHighlight = sourceBytes <= MAX_HIGHLIGHT_BYTES
				&& sourceLines.length <= MAX_HIGHLIGHT_LINES
				&& sourceLines.every((line) => Buffer.byteLength(line) <= MAX_HIGHLIGHT_LINE_BYTES);

			for (const [hunkIndex, hunk] of file.hunks.entries()) {
				if (hunkIndex > 0) {
					rendered.push(`${indent}${" ".repeat(numberWidth + 1)}${this.theme.fg("dim", "⋮")}`);
				}

				const highlighted = shouldHighlight
					? highlightCode(hunk.lines.map((line) => line.source).join("\n"), language)
					: [];
				for (const [lineIndex, line] of hunk.lines.entries()) {
					const value = line.marker === "-" ? line.oldLine : line.newLine;
					const color = line.marker === "+"
						? "toolDiffAdded"
						: line.marker === "-"
							? "toolDiffRemoved"
							: "toolDiffContext";
					const syntax = highlighted[lineIndex] ?? this.theme.fg(color, line.source);
					const content = line.marker === "-" ? `\x1b[2m${syntax}\x1b[22m` : syntax;
					const wrapped = wrapTextWithAnsi(content, contentWidth);

					for (const [wrapIndex, chunk] of wrapped.entries()) {
						const prefix = wrapIndex === 0
							? `${indent}${lineNumber(value, numberWidth, this.theme)} ${this.theme.fg(color, line.marker)}`
							: `${indent}${" ".repeat(numberWidth + 2)}`;
						const row = prefix + chunk;
						rendered.push(
							line.marker === "+"
								? paintBackground(row, width, [33, 58, 43])
								: line.marker === "-"
									? paintBackground(row, width, [74, 34, 29])
									: truncateToWidth(row, width, "", true),
						);
					}
				}
			}
		}

		return rendered;
	}
}

async function collectDiff(pi: ExtensionAPI, cwd: string): Promise<string | undefined> {
	const rootResult = await pi.exec("git", ["rev-parse", "--show-toplevel"], { cwd, timeout: 2_000 });
	if (rootResult.code !== 0) return undefined;
	const root = rootResult.stdout.trim();
	const hasHead = (await pi.exec("git", ["rev-parse", "--verify", "HEAD"], { cwd: root, timeout: 2_000 })).code === 0;
	const tracked = hasHead
		? await pi.exec("git", ["-c", "core.quotePath=false", "diff", "--no-ext-diff", "--no-color", "--find-renames", "HEAD", "--"], {
				cwd: root,
				timeout: 10_000,
			})
		: await pi.exec("git", ["-c", "core.quotePath=false", "diff", "--no-ext-diff", "--no-color", "--cached", "--"], {
				cwd: root,
				timeout: 10_000,
			});

	const untracked = await pi.exec("git", ["ls-files", "--others", "--exclude-standard", "-z"], {
		cwd: root,
		timeout: 5_000,
	});
	const chunks = [tracked.stdout.trimEnd()].filter(Boolean);

	for (const file of untracked.stdout.split("\0").filter(Boolean)) {
		const result = await pi.exec("git", ["-c", "core.quotePath=false", "diff", "--no-ext-diff", "--no-color", "--no-index", "--", "/dev/null", file], {
			cwd: root,
			timeout: 5_000,
		});
		if (result.stdout) chunks.push(result.stdout.trimEnd());
	}

	return chunks.join("\n");
}

export default function workflow(pi: ExtensionAPI): void {
	let goal: GoalState | undefined;

	function reconstructGoal(ctx: ExtensionContext): void {
		goal = undefined;
		for (const entry of ctx.sessionManager.getBranch()) {
			if (entry.type === "custom" && entry.customType === GOAL_ENTRY) goal = entry.data as GoalState | undefined;
		}
		updateGoalStatus(ctx);
	}

	function updateGoalStatus(ctx: ExtensionContext): void {
		if (!goal) {
			ctx.ui.setStatus("goal", undefined);
			return;
		}
		const label = goal.status === "active" ? "goal active" : "goal paused";
		ctx.ui.setStatus("goal", ctx.ui.theme.fg(goal.status === "active" ? "accent" : "warning", label));
	}

	function persistGoal(ctx: ExtensionContext): void {
		pi.appendEntry<GoalState | undefined>(GOAL_ENTRY, goal);
		updateGoalStatus(ctx);
	}

	pi.registerEntryRenderer<DiffData>(DIFF_ENTRY, (entry, _options, theme) =>
		new DiffComponent(entry.data ?? { diff: "" }, theme),
	);

	pi.registerCommand("diff", {
		description: "Show staged, unstaged, and untracked changes",
		handler: async (_args, ctx) => {
			const diff = await collectDiff(pi, ctx.cwd);
			if (diff === undefined) {
				ctx.ui.notify("Not inside a Git repository", "warning");
				return;
			}
			if (!diff) {
				ctx.ui.notify("Working tree is clean", "info");
				return;
			}
			pi.appendEntry<DiffData>(DIFF_ENTRY, { diff });
		},
	});

	pi.registerCommand("goal", {
		description: "Set, edit, pause, resume, view, or clear the session goal",
		handler: async (args, ctx) => {
			const value = args.trim();
			if (!value) {
				ctx.ui.notify(goal ? `${goal.status === "active" ? "Active" : "Paused"} goal:\n${goal.objective}` : "No goal set", "info");
				return;
			}

			if (value === "clear") {
				goal = undefined;
				persistGoal(ctx);
				ctx.ui.notify("Goal cleared", "info");
				return;
			}
			if (value === "pause" || value === "resume") {
				if (!goal) {
					ctx.ui.notify("No goal set", "warning");
					return;
				}
				goal = { ...goal, status: value === "pause" ? "paused" : "active" };
				persistGoal(ctx);
				ctx.ui.notify(`Goal ${goal.status}`, "info");
				return;
			}

			let objective = value;
			if (value === "edit") {
				if (!goal) {
					ctx.ui.notify("No goal set", "warning");
					return;
				}
				objective = (await ctx.ui.input("Edit goal", goal.objective))?.trim() ?? "";
				if (!objective) return;
			}

			if (objective.length > MAX_GOAL_LENGTH) {
				ctx.ui.notify(`Goal must be at most ${MAX_GOAL_LENGTH} characters`, "error");
				return;
			}
			goal = { objective, status: "active" };
			persistGoal(ctx);
			ctx.ui.notify("Goal set", "info");
		},
	});

	pi.on("session_start", async (_event, ctx) => reconstructGoal(ctx));
	pi.on("session_tree", async (_event, ctx) => reconstructGoal(ctx));
	pi.on("before_agent_start", async () => {
		if (!goal || goal.status !== "active") return;
		return {
			message: {
				customType: "goal-context",
				content: `[ACTIVE SESSION GOAL]\n${goal.objective}\n\nKeep this objective in view while handling the current request. Do not claim completion until the objective and required verification are complete.`,
				display: false,
			},
		};
	});
}
