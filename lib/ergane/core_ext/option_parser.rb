# frozen_string_literal: true

class OptionParser
  # Like order!, but leave any unrecognized --switches alone
  # instead of raising InvalidOption.
  def order_recognized!(args)
    extra_opts = []
    begin
      order!(args) { |a| extra_opts << a }
    rescue OptionParser::InvalidOption => e
      extra_opts << e.args[0]
      retry
    end
    args[0, 0] = extra_opts
  end
end
