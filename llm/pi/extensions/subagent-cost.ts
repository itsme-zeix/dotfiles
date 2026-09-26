import { readFileSync } from "node:fs";
import type { Usage } from "@earendil-works/pi-ai";
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

/** Token and cost totals in the flat shape pi-subagents reports them. */
type Totals = {
	input: number;
	output: number;
	cacheRead: number;
	cacheWrite: number;
	cost: number;
};

/** Usage as stored on session entries, where cost carries its own breakdown. */
type StoredUsage = {
	input?: number;
	output?: number;
	cacheRead?: number;
	cacheWrite?: number;
	cost?: { total?: number };
};

const ZERO: Totals = { input: 0, output: 0, cacheRead: 0, cacheWrite: 0, cost: 0 };

function normalize(usage: Partial<Totals> | undefined): Totals {
	return { ...ZERO, ...usage };
}

function add(into: Totals, from: Totals, sign = 1): void {
	into.input += sign * from.input;
	into.output += sign * from.output;
	into.cacheRead += sign * from.cacheRead;
	into.cacheWrite += sign * from.cacheWrite;
	into.cost += sign * from.cost;
}

function isZero(totals: Totals): boolean {
	return totals.input === 0 && totals.output === 0 && totals.cacheRead === 0
		&& totals.cacheWrite === 0 && totals.cost === 0;
}

function toUsage(totals: Totals): Usage {
	return {
		input: totals.input,
		output: totals.output,
		cacheRead: totals.cacheRead,
		cacheWrite: totals.cacheWrite,
		totalTokens: totals.input + totals.output + totals.cacheRead + totals.cacheWrite,
		// pi-subagents keeps no cost breakdown for children, so only the total is meaningful.
		cost: { input: 0, output: 0, cacheRead: 0, cacheWrite: 0, total: totals.cost },
	};
}

/** Totals for a run that finished inside its `subagent` call. */
function detailsTotals(details: unknown): Totals | undefined {
	if (!details || typeof details !== "object") return undefined;
	const { results, totalCost } = details as {
		results?: { usage?: Partial<Totals> }[];
		totalCost?: { inputTokens?: number; outputTokens?: number; costUsd?: number };
	};

	const totals: Totals = { ...ZERO };
	for (const result of results ?? []) add(totals, normalize(result?.usage));

	// Interrupted and older runs list results without usage, so fall back to the
	// run summary. It carries no cache breakdown, which is why it is second choice.
	if (isZero(totals) && totalCost) {
		totals.input = totalCost.inputTokens ?? 0;
		totals.output = totalCost.outputTokens ?? 0;
		totals.cost = totalCost.costUsd ?? 0;
	}

	return isZero(totals) ? undefined : totals;
}

/**
 * Child session paths from a `subagent_wait` result. The completion exposes them
 * as `artifactPaths.outputPath` despite the name, and older releases pointed that
 * field at an output markdown file, so only `.jsonl` paths are accepted.
 */
function completedSessionPaths(details: unknown): string[] {
	const completions = (details as {
		completions?: { results?: { artifactPaths?: { outputPath?: unknown } }[] }[];
	} | null)?.completions;
	if (!Array.isArray(completions)) return [];

	const paths: string[] = [];
	for (const completion of completions) {
		for (const child of completion?.results ?? []) {
			const path = child?.artifactPaths?.outputPath;
			if (typeof path === "string" && path.endsWith(".jsonl")) paths.push(path);
		}
	}
	return paths;
}

/**
 * A child session file is the only authoritative record of what an async child
 * spent. Its cost is not known when the child is launched, so it cannot ride on
 * the `subagent` result the way a foreground child's does.
 */
function sessionTotals(path: string): Totals | undefined {
	let contents: string;
	try {
		contents = readFileSync(path, "utf8");
	} catch {
		return undefined;
	}

	const totals: Totals = { ...ZERO };
	let sawUsage = false;
	for (const line of contents.split("\n")) {
		if (!line) continue;
		let entry: { type?: string; message?: { usage?: StoredUsage }; usage?: StoredUsage };
		try {
			entry = JSON.parse(line);
		} catch {
			continue;
		}
		const usage = entry.type === "message"
			? entry.message?.usage
			: entry.type === "branch_summary" || entry.type === "compaction"
				? entry.usage
				: undefined;
		if (!usage) continue;
		sawUsage = true;
		totals.input += usage.input ?? 0;
		totals.output += usage.output ?? 0;
		totals.cacheRead += usage.cacheRead ?? 0;
		totals.cacheWrite += usage.cacheWrite ?? 0;
		totals.cost += usage.cost?.total ?? 0;
	}
	return sawUsage ? totals : undefined;
}

/**
 * pi-subagents reports delegated spend under tool result `details`, which pi's
 * session totals ignore. Re-reporting it as `usage` puts it back into the footer,
 * `/session`, and RPC totals.
 *
 * Foreground children are counted from the totals on their `subagent` result.
 * Async children finish after their launch result, so they are counted when
 * `subagent_wait` delivers the completion, by reading each child's session file.
 * An async run whose completion arrives as a custom message wake cannot be
 * counted: custom messages carry no usage.
 */
export default function subagentCost(pi: ExtensionAPI): void {
	// Totals already reported per child session, so a resumed run contributes only
	// the spend that is new since its last report.
	const reported = new Map<string, Totals>();

	pi.on("tool_result", (event) => {
		// Leave usage set by the tool itself alone, so this stays correct if
		// pi-subagents ever reports its own.
		if (event.usage) return;

		if (event.toolName === "subagent") {
			const totals = detailsTotals(event.details);
			return totals ? { usage: toUsage(totals) } : undefined;
		}

		if (event.toolName !== "subagent_wait") return;

		const delta: Totals = { ...ZERO };
		for (const path of completedSessionPaths(event.details)) {
			const totals = sessionTotals(path);
			if (!totals) continue;
			add(delta, totals);
			add(delta, reported.get(path) ?? ZERO, -1);
			reported.set(path, totals);
		}
		return isZero(delta) ? undefined : { usage: toUsage(delta) };
	});
}
