# CHANGELOG

## [Unreleased]

## [0.1.0] - 2023-04-26

- Initial release

## [0.2.0] - 2026-02-08

### Added
- Dual DSL: class-based and block-based command definitions
- Zeitwerk autoloading
- Recursive subcommand resolution via Runner
- Tool base class with auto-created command base (`MyTool::Command`)
- Custom `command_class` for shared command behavior
- Colorized help output with box-drawing characters
- Did-you-mean suggestions for unknown commands (Levenshtein)
- `--help` and `--version` flag handling
- Core extensions (blank?, present?, try, underscore, demodulize, Array.wrap, Hash#&)
- OptionParser#order_recognized! for multi-level flag passthrough
