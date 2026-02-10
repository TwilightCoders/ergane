# frozen_string_literal: true

module Ergane
  module DSL
    class BlockDSL
      def initialize(command_class)
        @command_class = command_class
      end

      def run(&block)
        @command_class.define_method(:run) { |*args| instance_exec(*args, &block) }
      end

      private

      def respond_to_missing?(name, include_private = false)
        @command_class.respond_to?(name) || super
      end

      def method_missing(name, *args, **opts, &block)
        if @command_class.respond_to?(name)
          @command_class.public_send(name, *args, **opts, &block)
        else
          super
        end
      end
    end
  end
end
