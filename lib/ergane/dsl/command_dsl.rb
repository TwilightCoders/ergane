# frozen_string_literal: true

module Ergane
  module DSL
    module CommandDSL
      def description(text = nil)
        text ? (@description = text) : (@description || "")
      end

      def aliases(*names)
        names.any? ? (@aliases = names.flatten.map(&:to_sym)) : (@aliases || [])
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

      def command(name, aliases: [], &block)
        klass = Class.new(command_base_for(name))
        klass.command_name = name.to_sym
        klass.aliases(*aliases) if aliases.any?

        const_name = name.to_s.split("_").map(&:capitalize).join
        const_set(const_name, klass) if const_name.match?(/\A[A-Z]/)

        BlockDSL.new(klass).instance_eval(&block) if block
        klass
      end

      private

      def command_base_for(_name)
        self
      end
    end
  end
end
