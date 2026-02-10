# frozen_string_literal: true

class String
  # "DeployCommand" -> "deploy_command"
  # "Ergane::Deploy" -> "ergane/deploy"
  def underscore
    gsub("::", "/")
      .gsub(/([A-Z]+)([A-Z][a-z])/, '\1_\2')
      .gsub(/([a-z\d])([A-Z])/, '\1_\2')
      .tr("-", "_")
      .downcase
  end unless method_defined?(:underscore)

  # "Ergane::Deploy" -> "Deploy"
  def demodulize
    if (index = rindex("::"))
      self[(index + 2)..]
    else
      dup
    end
  end unless method_defined?(:demodulize)
end
