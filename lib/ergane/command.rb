# frozen_string_literal: true

module Ergane
  class Command
    include Concerns::Inheritance
    include Concerns::OptionHandling
    extend DSL::CommandDSL

    self.abstract_class = true

    class << self
      def command_name=(name)
        @command_name = name&.to_sym
        return unless @command_name

        parent = superclass
        if parent.respond_to?(:tool) && parent.abstract_class?
          parent.inherited_command_name_set(self)
        else
          register_subcommand(self)
        end
      end

      def command_name
        @command_name || derive_command_name
      end

      def terms
        [command_name, *aliases].compact.uniq
      end

      def subcommands
        @subcommands ||= {}
      end

      def inherited(subclass)
        super
        subclass.instance_variable_set(:@option_definitions, option_definitions.dup)
        subclass.instance_variable_set(:@argument_definitions, argument_definitions.dup)
        subclass.instance_variable_set(:@subcommands, {})
        register_subcommand(subclass)
      end

      private

      def derive_command_name
        return nil if self == Command || abstract_class?
        base = name&.demodulize
        return nil unless base
        base.sub(/Command$/, "").underscore.to_sym
      end

      def register_subcommand(subclass)
        parent = subclass.superclass
        return if parent == Command || parent.abstract_class?
        cmd_name = subclass.command_name
        return unless cmd_name
        parent.subcommands[cmd_name] = subclass
      end
    end

    attr_reader :options

    def abbreviate_path(path)
      Ergane.paths.abbreviate(path)
    end

    def initialize(argv = [])
      @options = self.class.build_default_options
      @argv = process_arguments(parse_options(argv.dup))
    end

    def args
      @argv
    end

    def run(*run_args)
      if self.class.subcommands.any?
        $stdout.puts HelpFormatter.new(self.class).format
      else
        raise AbstractCommand, "#{self.class.name}#run is not implemented"
      end
    end

    private

    # Validates and coerces positional args against the command's argument
    # definitions: missing required args raise, absent optional args take
    # their default, and present args are coerced by type. Extra positionals
    # beyond the declared arguments pass through untouched (e.g. for run(*)).
    def process_arguments(argv)
      definitions = self.class.argument_definitions
      return argv if definitions.empty?

      declared = definitions.each_with_index.map do |defn, i|
        if i < argv.length
          coerce_argument(argv[i], defn)
        elsif defn.required
          raise MissingArgument, "Missing required argument: <#{defn.name}>"
        else
          defn.default
        end
      end
      declared + argv.drop(definitions.length)
    end

    def coerce_argument(value, defn)
      type = defn.type
      return value if type.nil? || type == String

      if type == Integer
        Integer(value)
      elsif type == Float
        Float(value)
      else
        value
      end
    rescue ArgumentError
      raise InvalidOption, "Invalid value for <#{defn.name}>: #{value.inspect} (expected #{type})"
    end
  end
end
