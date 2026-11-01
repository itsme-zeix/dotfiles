---
name: python-best-practices
description: Python best practices. Use when reading or editing any .py file.
paths: ["**/*.py"]
---

# Python best practices

These are defaults, not fixed rules. When one doesn't fit the case in front of you, do what fits and say why.

Target Python 3.12+ unless the project's `requires-python` says otherwise. Don't write code, version checks, or compatibility shims for older versions.

## Types and modeling

| Rule | Summary |
|------|---------|
| Simple precise types | Use precise types when they stay simple. Don't use `cast`, `Any`, or `# type: ignore` just to hide a real type error. |
| Modern syntax | `X \| None`, `A \| B`, `list[int]`, `collections.abc.Callable`. Not `Optional`, `Union`, `typing.List`, or `typing.Callable`. |
| Generics and aliases | `type Alias = ...`, `def f[T](x: T) -> T`, `class Box[T]:`. Not `TypeVar`, `Generic`, or `TypeAlias`. |
| Tagged unions | Model variants as separate dataclasses joined in a union (`type Shape = Circle \| Square`), not one class with a bag of optional fields. |
| Exhaustiveness | When matching on a union, end with `case _: assert_never(x)` so a new variant fails the type check. |
| Narrowing | `match` or `isinstance` first, then a `TypeIs` guard (`typing_extensions` before 3.13), then `cast` only after the value is checked. A guard must check what it claims. Name it `is_x`. |
| Distinct IDs | Use `NewType` when mixing up two values of the same type, such as a user ID and an order ID, would be a real bug. Create them where the input is checked. |
| `Self` and `override` | `typing.Self` for methods that return their own class. `@typing.override` on overriding methods. |

## Data and functions

| Rule | Summary |
|------|---------|
| Dataclasses | `@dataclass(slots=True)` instead of a hand-written `__init__`. Add `frozen=True` or `kw_only=True` when they fit. Leave out `slots` when the class uses `functools.cached_property`. |
| Outside data | Parse it where it enters with the project's schema library, such as pydantic or msgspec, not hand-written dict checks. Pass the parsed object along, not the raw dict. |
| "Not passed" | `None` means no value. When `None` is valid and you need "not passed", use `MISSING = Sentinel("MISSING")` from `typing_extensions`, annotated as `int \| MISSING`. Not `object()`. |
| Dict merging | `a \| b` and `a \|= b`, not `{**a, **b}` or `dict(a, **b)`. |
| Keyword-only args | Put `*` before parameters that are unclear by position, especially booleans and several values of the same type. |

## Standard library and runtime

| Rule | Summary |
|------|---------|
| Modern stdlib | `pathlib`, not `os.path`. `datetime.now(UTC)`, not `utcnow()`. `importlib.metadata` and `importlib.resources`, not `pkg_resources`. |
| Async | Prefer `asyncio.TaskGroup` so one failure cancels the other tasks. When the others should keep running, use `asyncio.gather(..., return_exceptions=True)` and handle each result. |
| `match` | Use it when it's clearer than an if/elif chain over shapes or types. |
| Exceptions | Catch the narrowest exception you can handle. Catch broad ones only at a top-level boundary, such as a CLI entry point or request handler. When you re-raise as a new type, use `raise NewError(...) from err`. |
| Subprocess | `subprocess.run([...], check=True)`. No `shell=True` unless you need shell features. |
| Imports | At the top of the module. Import inside a function only to break an import cycle or delay a heavy optional dependency. |
| Logging | `logging.getLogger(__name__)`, with enough context to debug from an ID. No `print` for diagnostics in shipped code. |
| uv | If the project has a `uv.lock`, use `uv run` and `uv add`, not `pip` or a manually activated venv. |
