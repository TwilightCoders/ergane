# frozen_string_literal: true

module Ergane
  # An ordered registry of path-prefix → label substitutions, used by
  # Command#abbreviate_path. Ships with $HOME → "~"; consumers register
  # their own, e.g.:
  #
  #   Ergane.paths.register("~/Workspace", "@ws")
  #
  # When abbreviating, the longest matching prefix wins, and a prefix only
  # matches at a path boundary so "/home/user" never clips "/home/username".
  class PathRegistry
    Substitution = Struct.new(:prefix, :label)

    def initialize
      @substitutions = []
    end

    # Register a +prefix+ to collapse to +label+. The prefix is expanded
    # (so "~" and relative paths resolve), and re-registering a prefix
    # replaces its previous label. Returns self for chaining.
    def register(prefix, label)
      expanded = File.expand_path(prefix.to_s)
      @substitutions.reject! { |sub| sub.prefix == expanded }
      @substitutions << Substitution.new(expanded, label.to_s)
      self
    end

    # Remove every registered substitution. Returns self for chaining.
    def clear
      @substitutions.clear
      self
    end

    # Collapse the longest matching prefix in +path+ to its label, returning
    # the path unchanged when nothing matches. The input is expanded before
    # matching (mirroring how prefixes are stored on #register), so matching
    # is consistent across platforms and "~"-relative input is accepted.
    def abbreviate(path)
      original = path.to_s
      expanded = File.expand_path(original)
      best = @substitutions
        .select { |sub| expanded == sub.prefix || expanded.start_with?("#{sub.prefix}/") }
        .max_by { |sub| sub.prefix.length }
      return original unless best

      "#{best.label}#{expanded[best.prefix.length..]}"
    end
  end
end
