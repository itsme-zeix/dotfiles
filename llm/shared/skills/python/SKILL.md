---
name: python
description: Python style preferences. Use when writing, editing, or reviewing Python code.
---

# Python

These are defaults, not fixed rules. When one doesn't fit the case in front of you, do what fits and say why.

Target Python 3.12+ unless the project's `requires-python` says otherwise. Don't write code, version checks, or compatibility shims for older versions.

- Use precise types when they stay simple. Don't use `cast`, `Any`, or `# type: ignore` just to hide a real type error.
- Types: `X | None` and `A | B`, not `Optional` or `Union`. Built-in generics (`list[int]`, `dict[str, int]`) and `collections.abc` (`Callable`, `Iterable`, `Mapping`), not `typing.List`, `typing.Dict`, or `typing.Callable`.
- Generics and aliases: `type Alias = ...`, `def f[T](x: T) -> T`, `class Box[T]:`. Not `TypeVar`, `Generic`, or `TypeAlias`.
- Use `typing.Self` for methods returning their own class and `@typing.override` on overriding methods.
- Merge dicts with `a | b` and `a |= b`, not `{**a, **b}` or `dict(a, **b)`.
- Use `None` for "no value". When `None` is a valid value and you need "not passed", use `MISSING = Sentinel("MISSING")` from `typing_extensions`, annotated as `int | MISSING`. Not `object()`.
- Use `@dataclass(slots=True)` (add `frozen=True` or `kw_only=True` when they fit) instead of hand-written `__init__`. Leave out `slots` when the class uses `functools.cached_property`.
- Use `pathlib`, not `os.path`. Use timezone-aware datetimes (`datetime.now(UTC)`), not `utcnow()`. Use `importlib.metadata` and `importlib.resources`, not `pkg_resources`.
- In async code, prefer `asyncio.TaskGroup` over `asyncio.gather`, so one failure cancels the other tasks. When the other tasks should keep running, use `asyncio.gather(..., return_exceptions=True)` and handle each result.
- Use `match` when it is clearer than an if/elif chain over shapes or types.
- Catch the narrowest exception you can handle. Catch broad exceptions only at a top-level boundary, such as a CLI entry point or request handler. When you re-raise as a different type, use `raise NewError(...) from err`.
- If the project uses uv (a `uv.lock` exists), use `uv run` and `uv add`, not `pip` or a manually activated venv.
- Call `subprocess.run` with a list of args and `check=True`. Don't use `shell=True` unless you need shell features.
- Put imports at the top of the module. Import inside a function only to break an import cycle or delay a heavy optional dependency.
