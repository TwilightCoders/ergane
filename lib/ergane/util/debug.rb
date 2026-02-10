# frozen_string_literal: true

module Ergane
  module Util
    module Debug
      def self.enabled?
        !!$ergane_debug
      end

      def self.enable!
        $ergane_debug = true
      end

      def self.disable!
        $ergane_debug = false
      end

      def self.log(message)
        return unless enabled?
        $stderr.puts "[Ergane DEBUG] #{message}"
      end
    end
  end
end
