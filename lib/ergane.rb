require 'active_support'
require 'active_support/core_ext'
require 'active_support/dependencies'
require 'optparse'
require 'colorize'
require 'notifier'
require 'pry-byebug'

$LOAD_PATH.unshift File.expand_path("#{__dir__}/ergane")

require 'ergane/version'
require 'ergane/command_definition'
require 'ergane/tool'

module Ergane

  Help = Class.new(StandardError)
  Interrupt = Class.new(StandardError)

  class << self
    attr_reader :logger

    def root(*args)
      (@root ||= Pathname.new(File.expand_path('../', __dir__))).join(*args)
    end

    def logger
      @logger ||= Logger.new($stdout).tap do |log|
        log.progname = @@active_tool&.title || self.name
        log.level = :warn
      end
    end

    # def debug(string)
    #   old_level = logger.level
    #   logger.level = :debug if $debug
    #   logger.debug(string)
    # ensure
    #   logger.level = old_level
    # end

    @@active_tool = nil

    def active_tool
      @@active_tool
    end

    def activate_tool(tool)
      previous_tool = @@active_tool
      @@active_tool = tool
      yield if block_given?
    ensure
      @@active_tool = previous_tool
    end

    def notify(message, title: nil, sound: nil, icon: nil, group: nil)
      cmd = ['terminal-notifier']
      cmd << "-group #{Process.pid}#{group}"
      cmd << "-title #{active_tool.label}"
      cmd << "-subtitle #{title}" if title
      cmd << "-appIcon 'assets/athena md-light-shadow.png'" if icon
      cmd << "-message '#{message}'"
      cmd << "-activate 'com.apple.Terminal'" # if macos
      cmd << "-sound #{sound}" if sound
      Thread.new { `afplay /System/Library/Sounds/#{sound == true ? 'Blow' : sound}.aiff` } unless sound == false

      `#{cmd.join(' ')}`
      # Notifier.notify(title: title, message: message, image: 'assets/athena md-light-shadow.png')
    end

    # Show a list of available extensions to use
    def extensions
      Extension.library
    end
  end
end

if ARGV.include?('--debug')
  $debug = true
  Ergane.logger.level = :debug
end

Dir[Ergane.root('lib', 'core_ext', "*.rb")].each do |path|
  require path
end
