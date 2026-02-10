# frozen_string_literal: true

module Ergane
  class HelpFormatter
    attr_reader :command_class, :command_path

    def initialize(command_class, command_path: [])
      @command_class = command_class
      @command_path = command_path
    end

    def format
      [
        description_section,
        version_section,
        usage_section,
        subcommands_section,
        options_section,
        arguments_section
      ].compact.join("\n\n") + "\n"
    end

    private

    def description_section
      desc = command_class.description
      desc if desc.present?
    end

    def version_section
      ver = command_class.respond_to?(:version) && command_class.version
      "Version: #{ver.to_s.light_blue}" if ver
    end

    def usage_section
      path = command_path.any? ? command_path.join(" ") : command_class.command_name.to_s
      usage = path.light_red
      usage += " [options]".light_cyan if command_class.option_definitions.any?
      usage += " [subcommand]".light_black.underline if command_class.subcommands.any?
      command_class.argument_definitions.each do |arg|
        label = arg.required ? "<#{arg.name}>" : "[#{arg.name}]"
        usage += " #{label}".light_yellow
      end
      "Usage:".light_cyan + " " + usage
    end

    def subcommands_section
      subs = command_class.subcommands
      return if subs.empty?

      max_width = subs.keys.map { |k| k.to_s.length }.max
      Util::Formatting.reset_colors!

      lines = []
      lines << "Subcommands:".light_cyan
      header_len = lines.last.uncolorize.length
      lines << ("  \u250C" + ("\u2500" * (header_len - 2)) + "\u2518").light_black

      subs.each do |name, sub_class|
        label = name.to_s.ljust(max_width + 2)
        desc = sub_class.description.present? ? sub_class.description.light_black : ""
        lines << "  \u251C\u2500\u2510".light_black + " #{label.send(Util::Formatting.next_color)} #{desc}"
      end

      lines << ("  \u2514" + "\u2500" * 40).light_black
      lines.join("\n")
    end

    def options_section
      opts = command_class.option_definitions
      return if opts.empty?

      max_width = opts.values.map { |o| o.signature.length }.max

      lines = ["Options:".light_cyan]
      opts.each_value do |opt|
        sig = opt.signature.ljust(max_width + 2)
        desc = opt.description || ""
        default_note = opt.default_value ? " (default: #{opt.default_value})".light_black : ""
        lines << "  #{sig.light_green} #{desc}#{default_note}"
      end
      lines.join("\n")
    end

    def arguments_section
      args = command_class.argument_definitions
      return if args.empty?

      max_width = args.map { |a| a.name.to_s.length }.max

      lines = ["Arguments:".light_cyan]
      args.each do |arg|
        label = arg.name.to_s.ljust(max_width + 2)
        desc = arg.description || ""
        req = arg.required ? " (required)".light_red : " (optional)".light_black
        lines << "  #{label.light_yellow} #{desc}#{req}"
      end
      lines.join("\n")
    end
  end
end
