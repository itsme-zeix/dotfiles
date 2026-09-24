import type { ExtensionAPI, ExtensionContext } from "@earendil-works/pi-coding-agent";
import { truncateToWidth, visibleWidth } from "@earendil-works/pi-tui";

type ProjectState = {
	changedFiles?: number;
	prNumber?: string;
	tokensPerSecond?: number;
};

const FOOTER_PADDING = 1;

function formatTokens(count: number): string {
	if (count < 1_000) return String(count);
	if (count < 10_000) return `${(count / 1_000).toFixed(1)}k`;
	if (count < 1_000_000) return `${Math.round(count / 1_000)}k`;
	return `${(count / 1_000_000).toFixed(1)}M`;
}

function fitSides(left: string, right: string, width: number): string {
	if (!right) return truncateToWidth(left, width, "...");

	const gap = 2;
	const rightWidth = Math.min(visibleWidth(right), Math.floor(width * 0.45));
	const fittedRight = truncateToWidth(right, rightWidth, "...");
	const leftWidth = Math.max(0, width - visibleWidth(fittedRight) - gap);
	const fittedLeft = truncateToWidth(left, leftWidth, "...");
	const padding = " ".repeat(Math.max(gap, width - visibleWidth(fittedLeft) - visibleWidth(fittedRight)));
	return fittedLeft + padding + fittedRight;
}

function sessionCost(ctx: ExtensionContext): number {
	let cost = 0;
	for (const entry of ctx.sessionManager.getEntries()) {
		if (entry.type === "message" && entry.message.role === "assistant") {
			cost += entry.message.usage.cost.total;
		} else if (entry.type === "message" && entry.message.role === "toolResult" && entry.message.usage) {
			cost += entry.message.usage.cost.total;
		} else if ((entry.type === "branch_summary" || entry.type === "compaction") && entry.usage) {
			cost += entry.usage.cost.total;
		}
	}
	return cost;
}

function displayCwd(cwd: string): string {
	const home = process.env.HOME || process.env.USERPROFILE;
	return home && (cwd === home || cwd.startsWith(`${home}/`)) ? `~${cwd.slice(home.length)}` : cwd;
}

export default function projectStatus(pi: ExtensionAPI): void {
	const state: ProjectState = {};
	let requestRender: (() => void) | undefined;

	async function refreshProject(ctx: ExtensionContext): Promise<void> {
		const [git, pr] = await Promise.all([
			pi.exec("git", ["status", "--porcelain"], { cwd: ctx.cwd, timeout: 2_000 }).catch(() => undefined),
			pi
				.exec("gh", ["pr", "view", "--json", "number", "--jq", ".number"], {
					cwd: ctx.cwd,
					timeout: 3_000,
				})
				.catch(() => undefined),
		]);

		state.changedFiles = git?.code === 0 ? git.stdout.split("\n").filter(Boolean).length : undefined;
		state.prNumber = pr?.code === 0 && pr.stdout.trim() ? pr.stdout.trim() : undefined;
		requestRender?.();
	}

	pi.on("session_start", async (_event, ctx) => {
		if (ctx.mode !== "tui") return;

		ctx.ui.setFooter((tui, theme, footerData) => {
			requestRender = () => tui.requestRender();
			const unsubscribe = footerData.onBranchChange(() => tui.requestRender());

			return {
				dispose() {
					unsubscribe();
					requestRender = undefined;
				},
				invalidate() {},
				render(width: number): string[] {
					const branch = footerData.getGitBranch();
					const separator = theme.fg("dim", " │ ");
					const primary = [
						theme.fg("mdHeading", ctx.model?.id ?? "no-model"),
						theme.fg("mdHeading", ctx.thinkingLevel ?? "off"),
						theme.fg("success", displayCwd(ctx.cwd)),
					];
					if (branch) primary.push(theme.fg("syntaxKeyword", `(${branch})`));
					if (state.changedFiles !== undefined) {
						primary.push(
							theme.fg(
								state.changedFiles === 0 ? "success" : "thinkingMedium",
								state.changedFiles === 0 ? "[clean]" : `[${state.changedFiles} changed]`,
							),
						);
					}
					if (state.prNumber) primary.push(theme.fg("syntaxKeyword", `PR #${state.prNumber}`));

					const statuses = Array.from(footerData.getExtensionStatuses().entries())
						.map(([key, status]) =>
							key === "sandbox"
								? theme.fg("muted", "sandbox")
								: status.replace(/[\r\n\t]/g, " ").trim(),
						)
						.filter(Boolean)
						.join(" ");

					const context = ctx.getContextUsage();
					const contextWindow = context?.contextWindow ?? ctx.model?.contextWindow ?? 0;
					const percent = context?.percent == null ? "?" : context.percent.toFixed(1);
					const contextColor = context?.percent != null && context.percent > 90
						? "error"
						: context?.percent != null && context.percent > 70
							? "warning"
							: "success";
					const metrics = [
						theme.fg("syntaxNumber", `$${sessionCost(ctx).toFixed(3)}`),
						theme.fg(contextColor, `${percent}%/${formatTokens(contextWindow)}`),
					];
					if (state.tokensPerSecond !== undefined) {
						metrics.push(theme.fg("muted", `${state.tokensPerSecond.toFixed(1)} tps`));
					}

					if (statuses) primary.push(statuses);

					const contentWidth = Math.max(1, width - FOOTER_PADDING * 2);
					return [
						" ".repeat(FOOTER_PADDING)
							+ fitSides(primary.join(separator), metrics.join(separator), contentWidth)
							+ " ".repeat(FOOTER_PADDING),
					];
				},
			};
		});

		await refreshProject(ctx);
	});

	pi.on("message_end", (event, ctx) => {
		if (event.message.role !== "assistant" || event.message.usage.output <= 0) return;

		const elapsedSeconds = (Date.now() - event.message.timestamp) / 1_000;
		if (elapsedSeconds > 0) state.tokensPerSecond = event.message.usage.output / elapsedSeconds;
		requestRender?.();
	});

	pi.on("agent_settled", (_event, ctx) => {
		void refreshProject(ctx);
	});

	pi.on("session_shutdown", (_event, ctx) => {
		ctx.ui.setFooter(undefined);
		requestRender = undefined;
	});

	pi.registerCommand("status-refresh", {
		description: "Refresh project status in the footer",
		handler: async (_args, ctx) => refreshProject(ctx),
	});
}
