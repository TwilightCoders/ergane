# frozen_string_literal: true

require "zeitwerk"
require "optparse"
require "colorize"

# Eager-loaded (not autoloadable by convention)
require_relative "ergane/errors"
require_relative "ergane/core_ext/string"
require_relative "ergane/core_ext/object"
require_relative "ergane/core_ext/array"
require_relative "ergane/core_ext/hash"
require_relative "ergane/core_ext/option_parser"

module Ergane
  LOADER = Zeitwerk::Loader.new.tap do |loader|
    loader.tag = "ergane"
    loader.inflector.inflect(
      "dsl" => "DSL",
      "command_dsl" => "CommandDSL",
      "block_dsl" => "BlockDSL"
    )
    loader.push_dir(File.expand_path("..", __FILE__))
    loader.ignore(File.expand_path("ergane/errors.rb", __dir__))
    loader.ignore(File.expand_path("ergane/core_ext", __dir__))
    loader.ignore(File.expand_path("ergane.rb", __dir__))
    loader.setup
  end

  def self.root
    @root ||= Pathname.new(File.expand_path("../..", __FILE__))
  end
end
