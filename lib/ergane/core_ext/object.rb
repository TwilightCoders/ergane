# frozen_string_literal: true

class Object
  def blank?
    respond_to?(:empty?) ? !!empty? : !self
  end unless method_defined?(:blank?)

  def present?
    !blank?
  end unless method_defined?(:present?)

  def try(method_name = nil, *args, &block)
    if method_name
      respond_to?(method_name) ? public_send(method_name, *args, &block) : nil
    elsif block
      yield self
    end
  end unless method_defined?(:try)
end

class NilClass
  def blank? = true unless method_defined?(:blank?)
  def try(*) = nil unless method_defined?(:try)
end

class FalseClass
  def blank? = true unless method_defined?(:blank?)
end

class TrueClass
  def blank? = false unless method_defined?(:blank?)
end

class String
  # Catch whitespace-only strings, overriding the inherited Object#blank?.
  # Guarded on String's OWN methods — not method_defined?, which would see the
  # inherited Object#blank? and skip, leaving the whitespace-blind version. This
  # still defines our version normally, but yields to any external String#blank?
  # (e.g. ActiveSupport) rather than clobbering it.
  def blank?
    empty? || /\A[[:space:]]*\z/.match?(self)
  end unless instance_methods(false).include?(:blank?)
end

class Numeric
  def blank? = false unless method_defined?(:blank?)
end
