require 'ergane/command_definition'

module Ergane
  class Tool < CommandDefinition
    @@active_tool = nil

    def initialize(label, *paths)
      super(label)


      define do
        switches do
          switch :debug, default: false, kind: TrueClass, description: "Turn on debug mode"
          switch :help, default: false, kind: TrueClass, description: "Display this help block" do
            puts "raising Help"
            raise Help
          end
          # switch verbose: FalseClass, short: :v, "Turn on verbose logging"
        end

        run do
          begin
            Process.setproctitle('ergane')
            command, _other = self.parse_args(ARGV.dup)

            puts "Finished running #{label}"
          rescue Interrupt
            puts "\nOkay. Aborting."
          rescue RuntimeError
            binding.pry
          rescue Help
            puts "Print Help!"
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
      c = CommandDefinition.define(label, chain: chain, &block)

      parent_command = if chain.any?
        @@active_tool.dig(*chain)
      else
        @@active_tool
      end

      parent_command[label] = c
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
