# CHANGELOG

## [Unreleased]

## [0.2.0] - 2026-05-25

### Changed
- **Unknown subcommands on a command group now raise `CommandNotFound`** (with a did-you-mean suggestion) and exit non-zero, instead of silently printing help. Scoped to command groups — leaf commands still treat unmatched tokens as positional arguments.
- **Positional `argument` declarations are now enforced.** A missing `required:` argument raises `MissingArgument`; an absent optional argument takes its `default:`; values are coerced to the declared `type:` (`String` is identity, `Integer`/`Float` via Kernel conversion raising `InvalidOption` on bad input). Previously these keywords affected only help text.

### Added
- `Ergane::DSL::Macros.dsl_value` — a class-level getter/setter accessor generator used by the DSL.

### Fixed
- `PathRegistry#abbreviate` now expands its input before matching (mirroring `#register`), so abbreviation is consistent across platforms (notably Windows, where un-expanded inputs failed to match drive-qualified prefixes) and accepts `~`-relative input.
- `OptionParser#order_recognized!` no longer drops the trailing tokens of a multi-token unknown option, and preserves argument order.
- `String#blank?` is guarded against external definitions (e.g. ActiveSupport) instead of unconditionally overriding them.
- Tool-rooted abstract intermediate commands are no longer stranded in the tool's registry when marked abstract.

### Internal
- Command registration unified into a single `register!` path (removed the duplicate `define_singleton_method`'d `inherited`/`inherited_command_name_set` hooks).
- `HelpFormatter` renders through a shared `section` helper with a per-render color cycler (no module-level mutable state).
- `Util::Debug` is no longer packaged in the gem (dev-only tooling).

## [0.1.0] - 2026-05-25

First release of the rewritten framework. A near-complete rewrite of the
original `0.0.1` proof of concept.

### Added
- Dual DSL: class-based and block-based command definitions, both producing the same command tree
- Zeitwerk autoloading
- Recursive subcommand resolution via Runner
- Tool base class with auto-created command base (`MyTool::Command`)
- Custom `command_class` for shared command behavior
- Abstract commands for grouping shared options
- Colorized help output with box-drawing characters
- Did-you-mean suggestions for unknown commands (Levenshtein)
- `--help` and `--version` flag handling
- Options, flags, and positional arguments, with optional values for options
- Path abbreviation registry (`Ergane.paths` / `PathRegistry`): collapses registered prefixes (default `$HOME` → `~`), longest-prefix-wins and boundary-safe; commands call `abbreviate_path`
- Interactive output helpers: `Ergane::Formatter.confirm?` and `Ergane::Formatter.time_ago`
- Core extensions (`blank?`, `present?`, `try`, `underscore`, `demodulize`, `Array.wrap`, `Hash#&`)
- `OptionParser#order_recognized!` for multi-level flag passthrough

## [0.0.1] - 2023-05-08

- Initial release
