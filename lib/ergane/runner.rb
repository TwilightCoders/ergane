# frozen_string_literal: true

module Ergane
  class Runner
    attr_reader :root, :argv

    def initialize(root, argv)
      @root = root
      @argv = argv.dup
    end

    # Resolve the ARGV to a command class, instantiate, and run.
    def execute
      command_class, remaining, path = resolve(root, argv)

      if help_requested?(remaining)
        $stdout.puts HelpFormatter.new(command_class, command_path: path).format
        return
      end

      if version_requested?(remaining) && command_class.respond_to?(:version) && command_class.version
        $stdout.puts "#{command_class.command_name} #{command_class.version}"
        return
      end

      instance = command_class.new(remaining)
      args = instance.args
      instance.run(*args)
    end

    private

    def help_requested?(args)
      args.include?("--help") || args.include?("-h")
    end

    def version_requested?(args)
      args.include?("--version") || args.include?("-V")
    end

    # Walk the command tree, consuming subcommand tokens from argv.
    # Returns [CommandClass, remaining_argv, command_path].
    def resolve(command_class, args, path = [])
      path << (command_class.command_name || command_class.name || "command").to_s
      return [command_class, args, path] if args.empty?

      token = args.first

      # Don't treat flags as subcommand names
      return [command_class, args, path] if token.start_with?("-")

      sub = command_class.subcommands[token.to_sym]
      if sub
        args.shift
        resolve(sub, args, path)
      else
        [command_class, args, path]
      end
    end
  end
end
