import type { ExtensionAPI, ExtensionContext } from "@earendil-works/pi-coding-agent";
import { matchesKey } from "@earendil-works/pi-tui";

// Escape is reserved for app.interrupt, so registerShortcut cannot claim it; a raw
// terminal listener runs before the editor and can consume the key instead.
export default function escapeSendQueued(pi: ExtensionAPI): void {
	async function waitForIdle(ctx: ExtensionContext): Promise<void> {
		while (!ctx.isIdle()) await new Promise((resolve) => setTimeout(resolve, 20));
	}

	// Pi's abort moves queued messages into the editor, so read them back from there
	// with the editor emptied first, then restore the unsent draft.
	async function sendQueuedNow(ctx: ExtensionContext): Promise<void> {
		const draft = ctx.ui.getEditorText();
		ctx.ui.setEditorText("");
		ctx.abort();
		const queued = ctx.ui.getEditorText();
		ctx.ui.setEditorText(draft);
		await waitForIdle(ctx);
		pi.sendUserMessage(queued);
	}

	// Pi drops extension terminal listeners on session switch and reload, so no cleanup is needed.
	pi.on("session_start", (_event, ctx) => {
		ctx.ui.onTerminalInput((data) => {
			if (!matchesKey(data, "escape") || ctx.isIdle() || !ctx.hasPendingMessages()) return undefined;
			void sendQueuedNow(ctx);
			return { consume: true };
		});
	});
}
