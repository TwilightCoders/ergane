# frozen_string_literal: true

module Ergane
  class OptionDefinition
    attr_reader :name, :type, :short, :description, :default, :required

    def initialize(name, type = nil, short: nil, description: nil, default: nil, required: false)
      @name = name.to_sym
      @type = type
      @short = short&.to_s
      @description = description
      @default = default
      @required = required
    end

    def boolean?
      type.nil? || type == TrueClass || type == FalseClass
    end

    def default_value
      boolean? ? (default.nil? ? false : default) : default
    end

    # Register this option with a stdlib OptionParser instance.
    # When the option is encountered, its value is stored in +store+.
    def attach(parser, store)
      args = []
      args << "-#{short}" if short
      long_flag = "--#{name.to_s.tr('_', '-')}"
      long_flag += "=VALUE" unless boolean?
      args << long_flag
      args << type if type && !boolean?
      args << description if description

      parser.on(*args) do |value|
        store[name] = value
      end
    end
  end
end
