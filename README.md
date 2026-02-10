<img src="https://github.com/TwilightCoders/ergane/blob/main/media/ergane.png?raw=true" alt="Athena Ergane" width="400" style="float: right"/>

# Ergane

[![Version](https://img.shields.io/gem/v/ergane.svg)](https://rubygems.org/gems/ergane)
[![CI](https://github.com/TwilightCoders/ergane/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/TwilightCoders/ergane/actions/workflows/ci.yml)
[![Code Coverage](https://qlty.sh/badges/43c39f23-168e-475f-a9fd-1754eaca83e6/coverage.svg)](https://qlty.sh/gh/TwilightCoders/projects/ergane)
[![Maintainability](https://qlty.sh/badges/43c39f23-168e-475f-a9fd-1754eaca83e6/maintainability.svg)](https://qlty.sh/gh/TwilightCoders/projects/ergane)

A lightweight, powerful CLI framework for Ruby. Define commands using class inheritance or block DSL — both produce the same command tree.

An alternative to other similar utilities with a cleaner, more Ruby-native design.

Named after [Athena Ergane](https://en.wikipedia.org/wiki/Athena#Ergane), patron of craftsmen and toolmakers.

## Requirements

Ruby 3.1+

## Installation

```ruby
gem "ergane"
```

## Quick Start

```ruby
require "ergane"

class MyCLI < Ergane::Tool
  tool_name :mycli
  version "1.0.0"
  description "My awesome CLI tool"

  command :greet do
    description "Say hello"
    option :name, String, short: :n, default: "world"

    run { puts "Hello #{options[:name]}!" }
  end
end

MyCLI.start(ARGV)
```

```
$ mycli greet -n 'Johnny Appleseed'
Hello Johnny Appleseed!

$ mycli --help
My awesome CLI tool

Version: 1.0.0

Usage: mycli [options] [subcommand]

Subcommands:
  greet  Say hello

$ mycli greet --help
Say hello

Usage: greet [options]

Options:
  -n, --name=VALUE  (default: world)
```

## Defining Commands

Ergane supports two equivalent styles for defining commands. Both produce the same underlying `Command` subclass.

### Block-based DSL

Best for quick, self-contained commands:

```ruby
class MyCLI < Ergane::Tool
  tool_name :mycli
  version "1.0.0"

  command :deploy do
    description "Deploy the application"
    option :env, String, short: :e, default: "staging"
    flag :force, short: :f, description: "Skip confirmation"

    run do |*targets|
      puts "Deploying #{targets.join(', ')} to #{options[:env]}"
      puts "Force mode!" if options[:force]
    end
  end
end
```

### Class-based

Best for complex commands that need helper methods, mixins, or testing in isolation.

Defining a Tool automatically creates a `MyCLI::Command` base class for your commands to inherit from:

```ruby
class Deploy < MyCLI::Command
  self.command_name = :deploy
  description "Deploy the application"
  option :env, String, short: :e, default: "staging"
  flag :force, short: :f, description: "Skip confirmation"

  def run(*targets)
    puts "Deploying #{targets.join(', ')} to #{options[:env]}"
    puts "Force mode!" if options[:force]
  end

  private

  def confirm?
    return true if options[:force]
    # ...
  end
end
```

### Nested Subcommands

Both styles support nesting to arbitrary depth:

```ruby
class MyCLI < Ergane::Tool
  tool_name :mycli
  version "1.0.0"

  command :server do
    description "Server management"

    command :start do
      description "Start the server"
      option :port, String, short: :p, default: "3000"

      run { puts "Starting on port #{options[:port]}" }
    end

    command :stop do
      description "Stop the server"
      run { puts "Stopping server" }
    end
  end
end
```

```
$ mycli server start -p 8080
Starting on port 8080
```

## Options and Flags

```ruby
# Typed option (requires a value)
option :env, String, short: :e, description: "Target environment", default: "staging"

# Boolean flag (no value, defaults to false)
flag :verbose, short: :v, description: "Enable verbose output"

# Positional argument
argument :target, description: "Deploy target"
```

Options are accessed via the `options` hash:

```ruby
run do |*args|
  puts options[:env]      # => "staging"
  puts options[:verbose]  # => false
end
```

## Loading Commands from Files

For larger CLIs, organize commands in separate files:

```ruby
class MyCLI < Ergane::Tool
  tool_name :mycli
  version "1.0.0"

  load_commands(File.expand_path("commands/**/*.rb", __dir__))
end
```

Each file defines a Command subclass that auto-registers via Ruby's `inherited` hook:

```ruby
# commands/deploy.rb
class Deploy < MyCLI::Command
  self.command_name = :deploy
  description "Deploy the application"

  def run(*targets)
    # ...
  end
end
```

## Custom Command Base

For shared behavior across all commands, provide your own base class:

```ruby
class MyBaseCommand < Ergane::Command
  self.abstract_class = true
  flag :verbose, short: :v, description: "Verbose output"

  def log(msg)
    puts msg if options[:verbose]
  end
end

class MyCLI < Ergane::Tool
  tool_name :mycli
  version "1.0.0"
  command_class MyBaseCommand
end

class Deploy < MyBaseCommand
  self.command_name = :deploy
  description "Deploy the application"

  def run(*targets)
    log "Deploying #{targets.join(', ')}"
  end
end
```

## Abstract Commands

Group related commands with shared options:

```ruby
class DatabaseCommand < MyCLI::Command
  self.abstract_class = true
  option :database, String, short: :d, default: "primary"
end

class Migrate < DatabaseCommand
  self.command_name = :migrate
  description "Run migrations"

  def run
    puts "Migrating #{options[:database]}"
  end
end
```

## Development

After checking out the repo, run `bundle` to install dependencies. Then, run `bundle exec rspec` to run the tests.

## Contributing

Bug reports and pull requests are welcome on GitHub at
<https://github.com/TwilightCoders/ergane>. This project is intended to be a safe,
welcoming space for collaboration, and contributors are expected to adhere to the
[Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
