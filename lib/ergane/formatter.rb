# frozen_string_literal: true

module Ergane
  # Small, generic output helpers for interactive CLIs.
  module Formatter
    class << self
      # Prompt on stderr and return true only for an affirmative answer.
      # Returns false when stdin isn't a TTY (non-interactive / piped input).
      def confirm?(prompt)
        $stderr.print "#{prompt} [y/N] "
        return false unless $stdin.tty?

        answer = $stdin.gets&.strip
        answer&.match?(/\Ay(es)?\z/i)
      end

      # Humanize the distance from +time+ to now: "just now", "5m ago",
      # "3h ago", "2d ago".
      def time_ago(time)
        seconds = (Time.now - time).to_i
        return 'just now' if seconds < 60
        return "#{seconds / 60}m ago" if seconds < 3600
        return "#{seconds / 3600}h ago" if seconds < 86400

        "#{seconds / 86400}d ago"
      end
    end
  end
end
