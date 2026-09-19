---
name: technical-writing
description: Write or revise clear, concise, human technical prose. Use for documentation, READMEs, RFCs, design notes, runbooks, PR descriptions, commit messages, and technical explanations. Do not use for product UI copy or prose whose project has a more specific style guide.
---

# Technical writing

Write for a tired engineer who needs to understand the text on the first read. Preserve the author's meaning and tone. Treat project terminology, symbols, paths, commands, and measured results as facts to verify rather than prose to improvise.

## Work in this order

1. Identify the reader, purpose, and requested output.
2. Inspect the relevant code or source material before asserting technical facts.
3. Choose one document mode. Split and link when the material needs more than one.
4. Draft around the reader's task or question.
5. Remove ambiguity, filler, unsupported claims, and machine-like phrasing.
6. Check every symbol, path, command, count, and example against the current source.

Do not rewrite unchanged prose merely to impose a preference. When a rule makes the text less clear or less natural, fix the sentence another way or leave it alone.

## Choose one document mode

- **Tutorial:** Teach by building something. Produce visible results early, state expected output, and keep explanations brief enough to preserve momentum.
- **How-to:** Give the shortest dependable path to a concrete goal. Assume competence, put conditions before actions, and move background material elsewhere.
- **Reference:** Describe facts, options, limits, errors, and defaults for lookup. Mirror the structure and names of the system being documented.
- **Explanation:** Answer a bounded "why" question. Discuss context, constraints, decisions, alternatives, and trade-offs.

Apply the sentence and editing rules below to PR descriptions and commit messages, but do not force them into a document mode.

## Make each sentence easy to parse

- Use the project's exact name for each concept. Do not cycle through synonyms.
- Address the reader as "you" when useful. Write instructions as commands.
- Name the actor: "the compiler validates the query," not "the query is validated."
- Put a condition or warning before the action it controls.
- Keep one instruction per sentence and usually one thought per sentence.
- Split dense sentences when a reader must backtrack to parse them.
- Keep "only," "not," and similar modifiers beside the words they modify.
- Replace ambiguous pronouns with the noun when more than one referent is possible.
- Break up long noun strings and restore omitted articles or verbs.
- Prefer periods to semicolons or em dashes.
- Use numbered lists for sequences and bullets for non-sequential sets. Keep list items parallel.
- Use sentence-case headings with no skipped levels.

## Use plain, specific language

- Prefer "use," "help," "start," and "delete" over "utilize," "facilitate," "initiate," and "evacuate."
- Cut words that do no work. Replace "in order to" with "to" and delete "it is important to note."
- Replace abstract claims with mechanisms, examples, measurements, or commands.
- Name the source of a claim. Remove vague attributions such as "experts believe."
- Avoid promotional adjectives, puffery, generic conclusions, and formulaic challenge-and-triumph framing.
- Avoid invented metaphors such as "substrate," "north star," "flywheel," "ratchet," or "endgame" when a concrete term exists.
- Do not call a task simple, easy, or obvious.
- Keep code, flags, paths, and UI labels in their appropriate literal formatting.

## Keep a human voice

- Vary sentence length and rhythm without making the structure messy.
- State a view where the document mode permits one, especially when explaining trade-offs.
- Use first person when it fits the author and context.
- Prefer a specific reaction or consequence to sterile labels such as "concerning" or "significant."
- Remove chatbot openings, praise, canned reassurance, decorative emoji, excessive bolding, and generic offers to help.
- Avoid forced groups of three, "not just X but Y," false "from X to Y" ranges, and repeated colon-led mini-headings.
- Do not ban a common word mechanically. Rewrite only when the word makes the sentence vague, inflated, or generic.

## Review before returning

Confirm that:

1. The text answers the reader's task or question without a detour.
2. Every technical claim is supported by the supplied material or inspected source.
3. Each thing has one stable name.
4. Instructions use direct commands with conditions first.
5. No sentence carries avoidable ambiguity, filler, or unsupported certainty.
6. The result still sounds like the intended author rather than a style-checking machine.
