# frozen_string_literal: true

module Ergane
  class Tool < Command
    self.abstract_class = true

    class << self
      extend DSL::Macros

      dsl_value :version

      def command_class(klass = nil)
        if klass
          @command_class = klass
          wire_command_class(klass)
        else
          @command_class
        end
      end

      def tool_name(name = nil)
        name ? (self.command_name = name) : command_name
      end

      def start(argv = ARGV)
        Runner.new(self, argv.dup).execute
      rescue Interrupt
        $stderr.puts "\nAborted."
        exit 130
      rescue Ergane::Error => e
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

      def command_base_for(_name)
        command_class || self
      end

      def create_command_base(tool_subclass)
        return if tool_subclass.command_class

        base = Class.new(Ergane::Command)
        base.abstract_class = true
        tool_subclass.const_set(:Command, base)
        tool_subclass.command_class(base)
      end

      # Gives the tool's command base (and everything below it) a reference
      # back to the tool, so Command#registration_target can route
      # subcommands to the tool's registry.
      def wire_command_class(klass)
        tool = self
        klass.define_singleton_method(:tool) { tool }
      end
    end
  end
end
