import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

// `pi-mono-btw` implements `/btw` by intercepting raw input rather than calling
// `pi.registerCommand()`. That is what lets it run while the main agent is busy,
// but it also means Pi has no command to list, so `/btw` never appears in the
// slash-command menu.
//
// This extension adds only the suggestion. It deliberately does NOT register a
// command: registered commands take precedence over input expansion, so a real
// `/btw` command would shadow pi-mono-btw and break its mid-run behavior.
const COMMAND = "btw";
const DESCRIPTION = "Side question while the main agent runs (pi-mono-btw)";

export default function btwAutocomplete(pi: ExtensionAPI): void {
	pi.on("session_start", (_event, ctx) => {
		ctx.ui.addAutocompleteProvider((current) => ({
			async getSuggestions(lines, cursorLine, cursorCol, options) {
				const suggestions = await current.getSuggestions(lines, cursorLine, cursorCol, options);

				// Only the bare command token at the start of the line, e.g. "/bt".
				const beforeCursor = (lines[cursorLine] ?? "").slice(0, cursorCol);
				const match = beforeCursor.match(/^\/([^\s/]*)$/);
				if (!match) return suggestions;

				// A bare "/" is left alone so Pi's own command order is untouched.
				const query = (match[1] ?? "").toLowerCase();
				if (query === "" || !COMMAND.startsWith(query)) return suggestions;

				// Built-in slash items carry the name without the leading "/", and
				// the prefix is the whole typed token.
				const items = (suggestions?.items ?? []).filter((item) => item.label !== COMMAND);
				items.push({ value: COMMAND, label: COMMAND, description: DESCRIPTION });

				return { prefix: beforeCursor, items };
			},
			applyCompletion(lines, cursorLine, cursorCol, item, prefix) {
				return current.applyCompletion(lines, cursorLine, cursorCol, item, prefix);
			},
			shouldTriggerFileCompletion(lines, cursorLine, cursorCol) {
				return current.shouldTriggerFileCompletion?.(lines, cursorLine, cursorCol) ?? true;
			},
		}));
	});
}
