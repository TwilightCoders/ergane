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
      command_class.argument_definitions.each_with_index do |arg, i|
        label = command_class.argument_required?(i) ? "<#{arg.name}>" : "[#{arg.name}]"
        usage += " #{label}".light_yellow
      end
      "Usage:".light_cyan + " " + usage
    end

    def subcommands_section
      subs = command_class.subcommands
      return if subs.empty?

      max_width = subs.keys.map { |k| k.to_s.length }.max
      colors = Util::Formatting::COLORS.cycle
      title = "Subcommands"

      lines = [("  \u250C" + ("\u2500" * (title.length - 1)) + "\u2518").light_black]
      subs.each do |name, sub_class|
        label = name.to_s.ljust(max_width + 2)
        desc = sub_class.description.present? ? sub_class.description.light_black : ""
        lines << "  \u251C\u2500\u2510".light_black + " #{label.send(colors.next)} #{desc}"
      end
      lines << ("  \u2514" + "\u2500" * 40).light_black

      section(title, lines)
    end

    def options_section
      opts = command_class.option_definitions
      return if opts.empty?

      max_width = opts.values.map { |o| o.signature.length }.max

      lines = opts.each_value.map do |opt|
        sig = opt.signature.ljust(max_width + 2)
        desc = opt.description || ""
        default_note = opt.default_value ? " (default: #{opt.default_value})".light_black : ""
        "  #{sig.light_green} #{desc}#{default_note}"
      end
      section("Options", lines)
    end

    def arguments_section
      args = command_class.argument_definitions
      return if args.empty?

      max_width = args.map { |a| a.name.to_s.length }.max

      lines = args.each_with_index.map do |arg, i|
        label = arg.name.to_s.ljust(max_width + 2)
        desc = arg.description || ""
        req = command_class.argument_required?(i) ? " (required)".light_red : " (optional)".light_black
        "  #{label.light_yellow} #{desc}#{req}"
      end
      section("Arguments", lines)
    end

    # Renders a titled block: a cyan "Title:" header followed by its lines,
    # or nil when there are no lines (so #format compacts it away).
    def section(title, lines)
      return if lines.empty?

      ["#{title}:".light_cyan, *lines].join("\n")
    end
  end
end
