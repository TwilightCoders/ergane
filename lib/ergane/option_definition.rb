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

    def long_flag
      flag = "--#{name.to_s.tr('_', '-')}"
      flag += "=VALUE" unless boolean?
      flag
    end

    def short_flag
      "-#{short}" if short
    end

    def signature
      [("#{short_flag}," if short), long_flag].compact.join(" ")
    end

    def attach(parser, store)
      args = [short_flag, long_flag].compact
      args << type if type && !boolean?
      args << description if description

      parser.on(*args) { |value| store[name] = value }
    end
  end
end
