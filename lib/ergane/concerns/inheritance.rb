# frozen_string_literal: true

module Ergane
  module Concerns
    module Inheritance
      def self.included(base)
        base.extend(ClassMethods)
      end

      module ClassMethods
        def abstract_class=(value)
          @abstract_class = value
          # Re-run registration so the command leaves (or rejoins) its
          # registry to match its new abstract state.
          register! if self < Ergane::Command && respond_to?(:register!, true)
        end

        def abstract_class?
          @abstract_class == true
        end

        # Returns the class descending directly from Ergane::Command, or
        # an abstract class, if any, in the inheritance hierarchy.
        #
        # If A extends Command, A.base_class returns A.
        # If B < A through some hierarchy, B.base_class returns A.
        # If A is abstract, both B.base_class and C.base_class return B.
        def base_class
          unless self < Ergane::Command
            raise Ergane::Error, "#{name} doesn't belong in a hierarchy descending from Ergane::Command"
          end

          if superclass == Ergane::Command || superclass.abstract_class?
            self
          else
            superclass.base_class
          end
        end
      end
    end
  end
end
