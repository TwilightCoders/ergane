# frozen_string_literal: true

module Ergane
  class Tool < Command
    self.abstract_class = true

    class << self
      def command_class(klass = nil)
        if klass
          @command_class = klass
          wire_command_class(klass)
        else
          @command_class
        end
      end

      def tool_name(name = nil)
        if name
          self.command_name = name
        else
          command_name
        end
      end

      def version(ver = nil)
        if ver
          @version = ver
        else
          @version
        end
      end

      def start(argv = ARGV)
        runner = Runner.new(self, argv.dup)
        runner.execute
      rescue Interrupt
        $stderr.puts "\nAborted."
        exit 130
      rescue CommandNotFound => e
        $stderr.puts e.message
        exit 1
      rescue MissingArgument => e
        $stderr.puts e.message
        exit 1
      rescue AbstractCommand => e
        $stderr.puts e.message
        exit 1
      end

      def load_commands(*patterns)
        patterns.flatten.each do |pattern|
          Dir[pattern].sort.each { |file| require file }
        end
      end

      def inherited(subclass)
        super
        create_command_base(subclass) if self == Tool
      end

      private

      def create_command_base(tool_subclass)
        return if tool_subclass.command_class

        base = Class.new(Ergane::Command)
        base.abstract_class = true
        tool_subclass.const_set(:Command, base)
        tool_subclass.command_class(base)
      end

      def wire_command_class(klass)
        tool = self
        klass.define_singleton_method(:tool) { tool }

        klass.define_singleton_method(:inherited) do |subclass|
          super(subclass)
        end

        klass.define_singleton_method(:inherited_command_name_set) do |subclass|
          cmd_name = subclass.command_name
          tool.subcommands[cmd_name] = subclass if cmd_name && !subclass.abstract_class?
        end
      end
    end

    def self.command(name, aliases: [], &block)
      base = command_class || self
      klass = Class.new(base)
      klass.command_name = name.to_sym
      klass.aliases(*aliases) if aliases.any?

      const_name = name.to_s.split("_").map(&:capitalize).join
      const_set(const_name, klass) if const_name.match?(/\A[A-Z]/)

      Ergane::DSL::BlockDSL.new(klass).instance_eval(&block) if block
      klass
    end
  end
end
