module Ergane
  module Util

    def self.colors
      # @colors = [:red, :yellow, :green, :blue, :cyan, :magenta].cycle
      @colors ||= [:light_red, :light_yellow, :light_green, :light_blue, :light_cyan, :light_magenta].cycle
    end

    def self.color_array(array)
      array.collect do |a|
        a.to_s.send(colors.next.to_sym).underline
      end
    end

    def self.color_array!(array)
      colors.rewind
      array.collect do |a|
        a.to_s.send(colors.next.to_sym).underline
      end
    end

    def self.rainbow(string, delimeter=' ')
      rainbow_a(string.split(delimeter)).join(delimeter)
    end

    def self.rainbow!(string, delimeter=' ')
      rainbow_a!(string.split(delimeter)).join(delimeter)
    end

    def self.rainbow_a(array)
      array.collect do |a|
        a.to_s.send(next_color).underline
      end
    end

    def self.rainbow_a!(array)
      rainbow_colors.rewind
      array.collect do |a|
        a.to_s.send(next_color).underline
      end
    end

    def self.next_color
      colors.next
    end

    def self.rainbow_colors
      @rainbow_colors = [:light_red, :light_yellow, :light_green, :light_blue, :light_cyan, :light_magenta].cycle
    end

    def self.next_rainbow_color
      rainbow_colors.cycle
    end

    def self.full_name
      @full_name ||= `finger \`whoami\` | grep Name | awk -F 'Name: ' '{print $2}'`.chomp
    end

    def self.last_name
      @last_name || begin
        split_names.last
      end
    end

    def self.first_name
      @first_name || begin
        split_names.first
      end
    end

    private

    def self.split_names
      @first_name, @last_name = ful_name.split(' ')
    end
  end
end
