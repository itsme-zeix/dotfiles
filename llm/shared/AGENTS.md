# Working agreement

- **Ask when unclear.** If the intent, requirements, or design are unclear, ask before you change files. If no one is watching the run, pick a reasonable reading, go ahead, and say what you assumed.
- **Stay in scope.** Change only what the task needs, and don't use the rules below as a reason to refactor other code. Report other problems you notice instead of fixing them.
- **Suggest better approaches.** If a different approach would pay off over time, say so and explain the tradeoff. Ask before you widen the task.
- **Say what you don't know.** Sounding sure when you aren't does more damage than admitting you don't know. When it helps, run a small, safe experiment and report what it showed.

## Keep code easy to follow

- Simple code beats strict rules. If a rule here or in a skill would make the code harder to follow, skip it and say so.
- Make the smallest change that solves the problem. Before you add a helper, option, or layer, ask what it simplifies today, not someday.
- Delete before you add. Remove dead code, unused paths, and checks for cases that can't happen. When you replace an approach, remove the old one.
- Keep the path through the code short. Inline wrappers that have one caller and layers that only pass calls along. Prefer local variables and return values over shared state that changes.
- Fix the cause, not the symptom. When practical, reproduce the bug first.
- Check outside input where it enters the program: CLI args, config, files, network, and external APIs. Turn it into typed data there and trust it after that. Keep core logic in pure functions.
- If flags must stay in sync or the same if/else keeps growing, use a type, enum, state machine, or lookup table instead. Add new structure only when it removes branches or invalid states.

## Write tests that catch real bugs

- A test is code someone has to maintain. Add one only when it catches a meaningful failure that existing tests miss.
- Test behavior through the interface its users use. Don't test private methods, mock the code's own internal parts, or read database state directly. Check calls to outside systems only when those calls are part of the contract.
- Get expected values from the spec, a worked example, or a known-good literal. Never compute them with the code under test.
- Assert on results, structured values, and error types. Compare exact strings or use broad snapshots only when the exact text is part of the contract.
- Avoid monkeypatching. If it seems necessary, raise it with the user first and propose composition or dependency injection instead.
- Make sure the test works both ways: a real behavior bug must fail it, and a refactor that keeps behavior must not. Within the task's scope, rewrite or remove tests that don't meet this bar.
