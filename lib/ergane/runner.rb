# frozen_string_literal: true

module Ergane
  class Runner
    attr_reader :root, :argv

    def initialize(root, argv)
      @root = root
      @argv = argv.dup
    end

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
      instance.run(*instance.args)
    end

    private

    def help_requested?(args)
      args.include?("--help") || args.include?("-h")
    end

    def version_requested?(args)
      args.include?("--version") || args.include?("-V")
    end

    def resolve(command_class, args, path = [])
      path << (command_class.command_name || command_class.name || "command").to_s
      return [command_class, args, path] if args.empty?

      token = args.first
      return [command_class, args, path] if token.start_with?("-")

      sub = find_subcommand(command_class, token.to_sym)
      if sub
        args.shift
        resolve(sub, args, path)
      else
        [command_class, args, path]
      end
    end

    def find_subcommand(command_class, token)
      command_class.subcommands[token] ||
        command_class.subcommands.each_value.find { |cmd| cmd.terms.include?(token) }
    end
  end
end
