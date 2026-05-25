# frozen_string_literal: true

module Ergane
  module DSL
    # Helpers for defining DSL methods on a host class/module.
    module Macros
      # Defines a class-level "value" accessor with combined getter/setter
      # semantics: called with a truthy argument it stores and returns it;
      # called with none (or a falsy value) it returns the stored value, or
      # +default+ if unset.
      #
      #   dsl_value :description, default: ""
      #   description "Deploy"   # => "Deploy" (and stored)
      #   description            # => "Deploy"
      def dsl_value(name, default: nil)
        ivar = "@#{name}"
        define_method(name) do |value = nil|
          value ? instance_variable_set(ivar, value) : (instance_variable_get(ivar) || default)
        end
      end
    end
  end
end
