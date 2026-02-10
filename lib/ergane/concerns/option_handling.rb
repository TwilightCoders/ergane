# frozen_string_literal: true

module Ergane
  module Concerns
    module OptionHandling
      def self.included(base)
        base.extend(ClassMethods)
      end

      module ClassMethods
        def option_definitions
          @option_definitions ||= {}
        end

        def argument_definitions
          @argument_definitions ||= []
        end

        def build_default_options
          option_definitions.each_with_object({}) do |(name, defn), hash|
            hash[name] = defn.default_value
          end
        end

        def build_option_parser(store)
          ::OptionParser.new do |parser|
            option_definitions.each_value do |defn|
              defn.attach(parser, store)
            end
          end
        end
      end

      private

      def parse_options(argv)
        parser = self.class.build_option_parser(@options)
        parser.order_recognized!(argv)
        argv
      end
    end
  end
end
