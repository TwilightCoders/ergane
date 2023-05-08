require 'ergane/command'

module Ergane
  class Tool < Command
    @@active_tool = nil

    def initialize(*paths)
      super()

      define self.class.name do
        options do
          option :debug, FalseClass, "Turn on debug mode"
          # option verbose: FalseClass, short: :v, "Turn on verbose logging"
        end

        run do
          begin
            Process.setproctitle('ergane')

            # TODO: Parse all options
            options[:debug] = ARGV.include?('--debug')
          rescue Interrupt
            puts "\nOkay. Aborting."
          rescue RuntimeError

          ensure
            system "printf '\033]0;\007'"
          end
        end

      end

      Pry.config.prompt_name = "#{label} ".light_blue

      activate_tool do
        Ergane.logger.debug "Loading paths:"
        Array.wrap(paths).each do |path|
          Ergane.logger.debug "  - #{path}"
          Ergane::Tool.load_commands(path)
        end
      end
    end

    def self.define(label, chain: [], &block)
      c = Command.define(label, chain: chain, &block)
      @@active_tool.dig(*(chain + [label])) = c
    end

    def self.load_commands(path)
      Dir[Ergane.root(path)].each do |path|
        instance_eval(File.read(path), path.split('/').last)
      end
    end

    private

    def activate_tool(&block)
      self.class.activate_tool(self, &block)
    end

    def self.activate_tool(tool)
      previous_tool = @@active_tool
      @@active_tool = tool
      yield if block_given?
    ensure
      @@active_tool = previous_tool
    end

  end
end
