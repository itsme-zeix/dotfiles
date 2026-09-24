import path from "node:path";
import type { ExtensionAPI, ExtensionContext, Theme } from "@earendil-works/pi-coding-agent";
import { truncateToWidth, visibleWidth } from "@earendil-works/pi-tui";

const TIMER_ENTRY = "turn-timer";
const WORKED_LABEL_THRESHOLD_MS = 60_000;
const TITLE_FRAMES = ["⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏"];
// Pi's default braille rotation shifted down one dot row to align visually with text.
const WORKING_FRAMES = ["⠖", "⠲", "⢲", "⢰", "⣰", "⣠", "⣄", "⣆", "⡆", "⡖"];

type TimerEntry = {
	durationMs: number;
};

function formatDuration(durationMs: number): string {
	const totalSeconds = Math.max(0, Math.floor(durationMs / 1_000));
	const seconds = totalSeconds % 60;
	const totalMinutes = Math.floor(totalSeconds / 60);
	const minutes = totalMinutes % 60;
	const hours = Math.floor(totalMinutes / 60);

	if (hours > 0) return `${hours}h ${String(minutes).padStart(2, "0")}m ${String(seconds).padStart(2, "0")}s`;
	if (minutes > 0) return `${minutes}m ${String(seconds).padStart(2, "0")}s`;
	return `${seconds}s`;
}

function workingMessage(elapsedMs: number, theme: Theme): string {
	return [
		theme.bold(theme.fg("text", "Working")),
		theme.fg("muted", `(${formatDuration(elapsedMs)} • esc to interrupt)`),
	].join(" ");
}

class TimerDivider {
	constructor(
		private readonly data: TimerEntry,
		private readonly theme: Theme,
	) {}

	invalidate(): void {}

	render(width: number): string[] {
		const label = this.data.durationMs > WORKED_LABEL_THRESHOLD_MS
			? ` Worked for ${formatDuration(this.data.durationMs)} `
			: "";
		const left = "─";
		const right = "─".repeat(Math.max(0, width - visibleWidth(left + label)));
		return [truncateToWidth(this.theme.fg("dim", left + label + right), width, "")];
	}
}

export default function turnTimer(pi: ExtensionAPI): void {
	let startedAt: number | undefined;
	let interval: NodeJS.Timeout | undefined;
	let titleInterval: NodeJS.Timeout | undefined;
	let titleFrame = 0;
	let activeContext: ExtensionContext | undefined;
	let hadToolActivity = false;
	let wasAborted = false;

	function clearTimer(): void {
		if (interval) clearInterval(interval);
		interval = undefined;
	}

	function refreshWorkingMessage(): void {
		if (startedAt === undefined || !activeContext) return;
		activeContext.ui.setWorkingMessage(workingMessage(Date.now() - startedAt, activeContext.ui.theme));
	}

	function projectPath(cwd: string): string {
		const resolved = path.resolve(cwd);
		const project = path.basename(resolved);
		if (!project) return resolved;
		const parent = path.basename(path.dirname(resolved));
		return parent ? `.../${parent}/${project}` : `.../${project}`;
	}

	function baseTitle(ctx: ExtensionContext): string {
		const session = pi.getSessionName();
		return ["pi", session, `(${projectPath(ctx.cwd)})`].filter(Boolean).join(" ");
	}

	function refreshTitle(ctx: ExtensionContext): void {
		const frame = TITLE_FRAMES[titleFrame % TITLE_FRAMES.length];
		ctx.ui.setTitle(`${frame} ${baseTitle(ctx)}`);
		titleFrame++;
	}

	function startTitleAnimation(ctx: ExtensionContext): void {
		if (titleInterval) clearInterval(titleInterval);
		titleFrame = 0;
		refreshTitle(ctx);
		titleInterval = setInterval(() => refreshTitle(ctx), 80);
	}

	function stopTitleAnimation(ctx: ExtensionContext): void {
		if (titleInterval) clearInterval(titleInterval);
		titleInterval = undefined;
		titleFrame = 0;
		ctx.ui.setTitle(baseTitle(ctx));
	}

	function resetWorkingIndicator(ctx: ExtensionContext): void {
		clearTimer();
		stopTitleAnimation(ctx);
		ctx.ui.setWorkingMessage();
		ctx.ui.setWorkingIndicator();
		activeContext = undefined;
	}

	pi.registerEntryRenderer<TimerEntry>(TIMER_ENTRY, (entry, _options, theme) =>
		new TimerDivider(entry.data ?? { durationMs: 0 }, theme),
	);

	pi.on("session_start", (_event, ctx) => {
		ctx.ui.setTitle(baseTitle(ctx));
	});

	pi.on("session_info_changed", (_event, ctx) => {
		if (startedAt !== undefined) refreshTitle(ctx);
		else ctx.ui.setTitle(baseTitle(ctx));
	});

	pi.on("agent_start", (_event, ctx) => {
		if (startedAt !== undefined) return;
		startedAt = Date.now();
		hadToolActivity = false;
		wasAborted = false;
		activeContext = ctx;
		ctx.ui.setWorkingIndicator({
			frames: WORKING_FRAMES.map((frame) => ctx.ui.theme.fg("accent", frame)),
			intervalMs: 80,
		});
		startTitleAnimation(ctx);
		refreshWorkingMessage();
		interval = setInterval(refreshWorkingMessage, 1_000);
	});

	pi.on("tool_execution_start", () => {
		if (startedAt !== undefined) hadToolActivity = true;
	});

	pi.on("message_end", (event) => {
		if (startedAt === undefined || event.message.role !== "assistant" || event.message.stopReason !== "aborted") {
			return;
		}

		wasAborted = true;
		const durationMs = Date.now() - startedAt;
		if (durationMs <= WORKED_LABEL_THRESHOLD_MS) return;

		return {
			message: {
				...event.message,
				errorMessage: `Operation aborted (worked for ${formatDuration(durationMs)})`,
			},
		};
	});

	pi.on("agent_settled", (_event, ctx) => {
		if (startedAt === undefined) return;
		const durationMs = Date.now() - startedAt;
		const showDivider = hadToolActivity && !wasAborted;
		startedAt = undefined;
		hadToolActivity = false;
		wasAborted = false;
		resetWorkingIndicator(ctx);
		if (showDivider) pi.appendEntry<TimerEntry>(TIMER_ENTRY, { durationMs });
	});

	pi.on("session_shutdown", (_event, ctx) => {
		startedAt = undefined;
		hadToolActivity = false;
		wasAborted = false;
		resetWorkingIndicator(ctx);
	});
}
