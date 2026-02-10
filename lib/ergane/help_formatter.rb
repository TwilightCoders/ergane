# frozen_string_literal: true

module Ergane
  class HelpFormatter
    attr_reader :command_class, :command_path

    def initialize(command_class, command_path: [])
      @command_class = command_class
      @command_path = command_path
    end

    def format
      lines = []
      lines << description_section if command_class.description.present?
      lines << version_section if command_class.respond_to?(:version) && command_class.version
      lines << usage_section
      lines << subcommands_section if command_class.subcommands.any?
      lines << options_section if command_class.option_definitions.any?
      lines << arguments_section if command_class.argument_definitions.any?
      lines.compact.join("\n\n") + "\n"
    end

    private

    def description_section
      command_class.description
    end

    def version_section
      "Version: #{command_class.version.to_s.light_blue}"
    end

    def usage_section
      parts = ["Usage:".light_cyan]
      path = command_path.any? ? command_path.join(" ") : command_class.command_name.to_s
      usage = path.light_red
      usage += " [options]".light_cyan if command_class.option_definitions.any?
      usage += " [subcommand]".light_black.underline if command_class.subcommands.any?
      command_class.argument_definitions.each do |arg|
        label = arg.required ? "<#{arg.name}>" : "[#{arg.name}]"
        usage += " #{label}".light_yellow
      end
      parts << usage
      parts.join(" ")
    end

    def subcommands_section
      subs = command_class.subcommands
      return nil if subs.empty?

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
      return nil if opts.empty?

      max_width = opts.values.map { |o| option_signature(o).length }.max

      lines = ["Options:".light_cyan]
      opts.each_value do |opt|
        sig = option_signature(opt).ljust(max_width + 2)
        desc = opt.description || ""
        default_note = opt.default_value ? " (default: #{opt.default_value})".light_black : ""
        lines << "  #{sig.light_green} #{desc}#{default_note}"
      end
      lines.join("\n")
    end

    def arguments_section
      args = command_class.argument_definitions
      return nil if args.empty?

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

    def option_signature(opt)
      parts = []
      parts << "-#{opt.short}," if opt.short
      long = "--#{opt.name.to_s.tr('_', '-')}"
      long += "=VALUE" unless opt.boolean?
      parts << long
      parts.join(" ")
    end
  end
end
