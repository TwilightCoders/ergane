# frozen_string_literal: true

module Ergane
  module Util
    module Formatting
      COLORS = %i[light_red light_yellow light_green light_blue light_cyan light_magenta].freeze

      def self.color_cycle
        @color_cycle ||= COLORS.cycle
      end

      def self.next_color
        color_cycle.next
      end

      def self.reset_colors!
        @color_cycle = COLORS.cycle
      end

      def self.rainbow(string, delimiter = " ")
        string.split(delimiter).map { |word| word.to_s.send(next_color) }.join(delimiter)
      end

      def self.colorize_list(items)
        items.map { |item| item.to_s.send(next_color) }
      end
    end
  end
end
