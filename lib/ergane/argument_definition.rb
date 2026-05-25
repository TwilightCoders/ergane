# frozen_string_literal: true

module Ergane
  class ArgumentDefinition
    attr_reader :name, :type, :description, :required, :default

    # +required+ defaults to nil, meaning "derive from the run signature";
    # pass true/false to force it.
    def initialize(name, type = String, description: nil, required: nil, default: nil)
      @name = name.to_sym
      @type = type
      @description = description
      @required = required
      @default = default
    end
  end
end
