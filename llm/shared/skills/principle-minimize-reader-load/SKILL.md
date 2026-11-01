---
name: principle-minimize-reader-load
description: "Apply when reviewing or shaping code that's hard to trace. Count layers between question and answer, and hidden state in the reader's head; collapse one-caller wrappers and shrink mutable scope."
---

# Minimize Reader Load

Maintainability is the work a reader must do to understand code. Track two axes: **layers to trace** (indirections between the question and the answer) and **state to hold** (hidden or mutable context the reader must keep in their head). LOC, cyclomatic complexity, and "clean architecture" are proxies. Reader load is the thing that matters. The two axes are independent. A flat file with 50 globals can be as hard to reason about as a 6-layer adapter stack. Guard both.

- **Collapse layers** that cost more than they save: wrappers with one caller, adapters with no second implementation, speculative indirection that was never needed. Inline them.
- **Each layer should add something.** A layer that repeats the same methods and arguments as the one below it makes the reader trace one more step for nothing. Collapse pass-through layers.
- **An interface should hide more than it shows.** If a broad interface hides little, readers have to learn both the interface and the code behind it. Prefer boundaries that hide real decisions.
- **Shrink state scope:** prefer pure functions (returns over mutations), locals over fields, fields over module state, and module state over globals. Compute a value from its source instead of keeping a copy in sync.
- **Name the invariant at the boundary,** not in every consumer, so the reader learns it once.
- Before adding a layer or a piece of state, ask: does it reduce reader load elsewhere by at least as much?

**The test:** can a new reader answer "where does X come from?" and "what can change X?" in under 30 seconds? If not, cut layers or cut state.
