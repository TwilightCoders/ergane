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

      # MissingArgument from the constructor (a leaf was reached but the
      # required positional wasn't supplied) → show that leaf's help instead
      # of failing with a bare error. Matches the principle that "the user
      # didn't tell us enough" is always answered with "here's what I need."
      begin
        instance = command_class.new(remaining)
      rescue MissingArgument
        $stdout.puts HelpFormatter.new(command_class, command_path: path).format
        return
      end

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

      # Arg-driven descent: the leading non-flag token (if any) names a
      # subcommand. Promotion (find_subcommand below) lets a token match
      # a grandchild under a `promote_subcommands!`-flagged parent.
      unless args.empty? || args.first.start_with?("-")
        token = args.first
        sub = find_subcommand(command_class, token.to_sym)
        if sub
          args.shift
          return resolve(sub, args, path)
        elsif command_class.subcommands.any?
          # Group with no match — bad token, not a positional for a leaf.
          raise CommandNotFound.new(token, available: command_class.subcommands.keys)
        end
      end

      # `--help` and `--version` short-circuit the default fallthrough — the
      # user navigated to THIS level explicitly (root, if they typed only the
      # flag), and they want THIS level's help/version. Without this, a bare
      # `tool --help`/`tool --version` would walk the default chain (e.g.
      # session→resume) to a leaf: `--help` would show the leaf's help instead
      # of the root command listing, and `--version` would reach a leaf with no
      # version DSL, skip execute's version branch, and fall into OptionParser's
      # built-in `--version` handler (which aborts "version unknown").
      return [command_class, args, path] if help_requested?(args) || version_requested?(args)

      # Default fallthrough: no token to consume, but a child claimed the
      # default slot — keep walking. Recursive: a default may itself have
      # a default. Same recursion handles both descents.
      if (default_sub = command_class.default_subcommand)
        return resolve(default_sub, args, path)
      end

      [command_class, args, path]
    end

    def find_subcommand(command_class, token)
      direct = command_class.subcommands[token]
      return direct if direct

      via_term = command_class.subcommands.each_value.find { |c| c.terms.include?(token) }
      return via_term if via_term

      # Promotion: search one level into any direct child marked
      # `promote_subcommands!`. Collect all hits across promoting children;
      # zero → nil (caller handles), one → the grandchild, multiple →
      # AmbiguousCommand (force the user to disambiguate).
      promoted = command_class.subcommands.each_value
                              .select { |c| c.respond_to?(:promote_subcommands?) && c.promote_subcommands? }
                              .flat_map do |c|
        c.subcommands.each_value.select { |gc| gc.terms.include?(token) }.map { |gc| [c, gc] }
      end

      return nil if promoted.empty?

      if promoted.size > 1
        raise AmbiguousCommand.new(token, candidates: promoted.map { |parent, gc|
          "#{parent.command_name} #{gc.command_name}"
        })
      end

      promoted.first.last
    end
  end
end
