# frozen_string_literal: true

module Ergane
  class Error < StandardError; end

  class CommandNotFound < Error
    attr_reader :token, :available

    def initialize(token, available: [])
      @token = token
      @available = available
      suggestion = find_suggestion
      msg = "Unknown command: '#{token}'"
      msg += ". Did you mean '#{suggestion}'?" if suggestion
      msg += "\nAvailable commands: #{available.join(', ')}" if available.any?
      super(msg)
    end

    private

    def find_suggestion
      return nil if available.empty?
      best = available.min_by { |cmd| levenshtein(token.to_s, cmd.to_s) }
      dist = levenshtein(token.to_s, best.to_s)
      dist <= [token.to_s.length / 2, 3].max ? best : nil
    end

    def levenshtein(a, b)
      m, n = a.length, b.length
      return n if m.zero?
      return m if n.zero?

      d = Array.new(m + 1) { |i| i }
      (1..n).each do |j|
        prev = d[0]
        d[0] = j
        (1..m).each do |i|
          cost = a[i - 1] == b[j - 1] ? 0 : 1
          temp = d[i]
          d[i] = [d[i] + 1, d[i - 1] + 1, prev + cost].min
          prev = temp
        end
      end
      d[m]
    end
  end

  class MissingArgument < Error; end
  class InvalidOption < Error; end
  class AbstractCommand < Error; end
end
