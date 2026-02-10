# frozen_string_literal: true

module Ergane
  class ArgumentDefinition
    attr_reader :name, :type, :description, :required, :default

    def initialize(name, type = String, description: nil, required: true, default: nil)
      @name = name.to_sym
      @type = type
      @description = description
      @required = required
      @default = default
    end
  end
end
