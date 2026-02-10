# frozen_string_literal: true

module Ergane
  module DSL
    # Class-level DSL methods extended into Ergane::Command.
    # These are called during class body evaluation.
    module CommandDSL
      def description(text = nil)
        if text
          @description = text
        else
          @description || ""
        end
      end

      def aliases(*names)
        if names.any?
          @aliases = names.flatten.map(&:to_sym)
        else
          @aliases || []
        end
      end

      def option(name, type = nil, short: nil, description: nil, default: nil, required: false)
        option_definitions[name.to_sym] = OptionDefinition.new(
          name, type, short: short, description: description,
          default: default, required: required
        )
      end

      def flag(name, short: nil, description: nil)
        option(name, nil, short: short, description: description, default: false)
      end

      def argument(name, type = String, description: nil, required: true, default: nil)
        argument_definitions << ArgumentDefinition.new(
          name, type, description: description, required: required, default: default
        )
      end

      # Block-based subcommand definition.
      # Creates an anonymous Command subclass, evaluates the block, and
      # registers it as a subcommand of the receiver.
      def command(name, aliases: [], &block)
        klass = Class.new(self)
        klass.command_name = name.to_sym
        klass.aliases(*aliases) if aliases.any?

        # Give it a const name for inspect/debugging
        const_name = name.to_s.split("_").map(&:capitalize).join
        const_set(const_name, klass) if const_name.match?(/\A[A-Z]/)

        Ergane::DSL::BlockDSL.new(klass).instance_eval(&block) if block
        klass
      end
    end
  end
end
