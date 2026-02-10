# frozen_string_literal: true

class Hash
  # Hash intersection by keys. Values come from the receiver.
  #   {a: 1, b: 2} & {a: 10, c: 3}  # => {a: 1}
  def &(other)
    shared = keys & other.keys
    shared.each_with_object({}) { |k, h| h[k] = self[k] }
  end unless method_defined?(:&)
end
