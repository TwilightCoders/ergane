# frozen_string_literal: true

class OptionParser
  # Like order!, but leave any unrecognized --switches alone
  # instead of raising InvalidOption.
  def order_recognized!(args)
    leftover = []
    until args.empty?
      begin
        order!(args) { |nonopt| leftover << nonopt }
        break
      rescue OptionParser::InvalidOption => e
        leftover.concat(e.args)
      end
    end
    args.replace(leftover)
  end
end
