require 'active_support'
require 'active_support/core_ext'
require 'active_support/dependencies'
require 'optparse'
require 'colorize'
require 'notifier'
require 'pry-byebug'

module Ergane
  class << self
    attr_reader :logger

    def root(*args)
      (@root ||= Pathname.new(File.expand_path('../', __dir__))).join(*args)
    end

    def logger
      @logger ||= Logger.new($stdout).tap do |log|
        log.progname = self.name
        log.level = :warn
      end
    end

    # Show a list of available extensions to use
    def extensions
      Extension.library
    end
  end
end

Dir[Ergane.root('lib', 'core_ext', "*.rb")].each do |path|
  require path
end

ActiveSupport::Dependencies.autoload_paths << Ergane.root('lib/ergane')
