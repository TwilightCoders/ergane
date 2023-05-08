module Ergane
  class Tool < CommandDefinition
    attr_reader :title #capitalized :label
    attr_reader :version

    def initialize(label, *paths)
      super(label)

      @title = label.capitalize
      @version = VERSION

      # Dogfood-ing
      define do
        description "Basic CLI Tool"
        switches do
          switch :help, default: false, kind: TrueClass, description: "Display this help block" do
            raise Help
          end
          switch :version, default: false, kind: TrueClass, description: "Display the version" do
            # TODO: Push ARGV into a variable at the command level that can be manipulated by flags/switches
            # NOTE: This would allow a --version to morph into a version command and we could push all this logic to that.
            # Additional logic for --version would be -1 or --short etc.
            puts "#{@title} Version: #{Ergane::VERSION}"
            exit
          end
          # switch verbose: FalseClass, short: :v, "Turn on verbose logging"
        end

        run do
          begin
            command, args = self, []
            Process.setproctitle(label.to_s)
            command, args = self.parse_args(ARGV.dup)

            command.run(*args)
            puts "Finished running #{label}"
          rescue Interrupt
            puts "\nOkay. Aborting."
          rescue RuntimeError
            puts "RuntimeError"
            binding.pry
          rescue Help
            puts help(command, args)
          ensure
            system "printf '\033]0;\007'"
          end
        end
      end

      Pry.config.prompt_name = "#{title} ".light_blue

      load_commands(paths)
    end

    def help(command, args=[])
      missing_args = command.arguments.product([false]).to_h.merge(args.product([true]).to_h).map do |arg, is_missing|
        a = arg.to_s.light_black.underline.tap do |b|
          b.blink if is_missing
        end
      end.join(' ')

      command.switch_parser.banner = [].tap do |text|
        text << "About: #{description}"
        text << "Version:  #{version.to_s.light_blue}"
        text << "Usage: #{([label] + chain).join(' ').light_red} #{'[options]'.light_cyan} "
        if commands.any?
          text.last << "[subcommand]".light_black.underline
          text << ("    ┌" + ("─" * (text.last.uncolorize.length - 12)) + "┘").light_black
          commands.each do |key, command|
            # text << "    ├─┐".light_black + " #{(klass.terms.join(', ')).ljust(24, ' ')} ".send(Athena::Util.next_color) + klass.description.light_black
            text << "    ├─┐".light_black + " #{key.to_s.ljust(24, ' ')} " + command.description.light_black
          end
          text << ("    └" + "─" * 64).light_black
        else
          # text.last << command.arguments(missing_args.keys)
        end
        # text << list_examples if examples.any?
        text << "Options:".light_cyan
      end.join("\n")
      switch_parser
    end

    def self.define(label, chain: [], &block)
      c = CommandDefinition.define(label, chain: chain, &block)

      parent_command = if chain.any?
        Ergane.active_tool.dig(*chain)
      else
        Ergane.active_tool
      end

      parent_command[label] = c
    end

    def load_commands(paths)
      activate_tool do
        Ergane.logger.debug "Loading paths:"
        Array.wrap(paths).each do |path|
          Ergane.logger.debug "  - #{path}"
          Dir[path].each do |path|
            file = path.split('/').last
            Ergane.logger.debug "  - loading #{path.split('/').last(4).join('/')}"
            instance_eval(File.read(path), file)
          end
        end
      end
    end

    private

    def activate_tool(&block)
      Ergane.activate_tool(self, &block)
    end

  end
end
