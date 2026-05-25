# CHANGELOG

## [Unreleased]

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
