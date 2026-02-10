# frozen_string_literal: true

module Ergane
  module DSL
    # Evaluation context for block-based command definitions.
    # Translates block DSL calls into class-level DSL calls on the
    # underlying Command subclass.
    class BlockDSL
      def initialize(command_class)
        @command_class = command_class
      end

      def description(text)
        @command_class.description(text)
      end

      def aliases(*names)
        @command_class.aliases(*names)
      end

      def option(name, type = nil, **opts)
        @command_class.option(name, type, **opts)
      end

      def flag(name, **opts)
        @command_class.flag(name, **opts)
      end

      def argument(name, type = String, **opts)
        @command_class.argument(name, type, **opts)
      end

      def command(name, **opts, &block)
        @command_class.command(name, **opts, &block)
      end

      def run(&block)
        @command_class.define_method(:run) do |*args|
          instance_exec(*args, &block)
        end
      end
    end
  end
end
