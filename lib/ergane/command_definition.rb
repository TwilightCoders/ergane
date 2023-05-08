# IDEA: "switches" are just "inline commands".
#       They share a similar structure to a command.
#       They have a label, description, and optionally a "run block"

require 'pry'
require 'helpers/hashall'
require 'switch_definition'

module Ergane

  class CommandDefinition < Hashall

    attr_reader :label
    attr_reader :chain
    attr_reader :description
    attr_reader :switch_definitions
    attr_reader :switch_parser
    attr_reader :requirements_block
    attr_reader :run_block

    def pretty_print(q)
      q.text "#{self.class.name} (#{label})"
      q.text "\n\tCommands:"
      q.group(1, " {", "}") do
        self.each_pair do |key, value|
          q.breakable
          q.text "#{key}: #{value}"
        end
      end
    end

    def run(*args)
      if run_block
        instance_exec(&requirements_block) if requirements_block
        instance_exec(*args, &run_block) if run_block
      else
        puts "show help for this command"
      end
    end

    def self.define(label, chain: [], &block)
      new(label, *chain).tap do |c|
        c.define(chain: chain, &block)
      end
    end

    def define(chain: [], &block)
      dsl_parse(&block)
    end

    def commands
      self.to_h
    end

    def arguments
      if commands.any?
        commands.keys
      else
        instance_method(:run).parameters.map { |arg| arg[1] }
      end
    end

    def default_switches
      @default_switches ||= switch_definitions.inject({}) do |collector, (label, switch)|
        collector[label] = switch.default
        collector
      end
      @default_switches.dup
    end

    def parse_args(args, path = [])
      if args.any? && args.first.match(/\A(\w+)\z/) && word = args.first.to_sym
        case command = self[word]
        when CommandDefinition
          path << args.shift
          command.parse_args(args, path)
        else
          puts "no such subcommand #{word} for #{self}"
        end
      else
        # These are args for this command now.
        Ergane.logger.debug "Now, process these args #{args} for #{label}"
        switch_parser.order_recognized!(args)
        [self, args || []]
      end
    end

    protected

    def dsl_parse(&block)
      dsl = DSL.new.tap do |dsl|
        dsl.instance_eval(&block)
      end
      @switch_definitions.merge!(dsl.config.delete(:switch_definitions))
      dsl.config.each do |k, v|
        begin
          instance_variable_set("@#{k}", v)
        rescue
          binding.pry
        end
      end

      switches = default_switches
      switch_definitions.values.each do |o|
        o.attach(@switch_parser, self) do |value|
          value = case o.kind
          when TrueClass
            true
          when FalseClass
            false
          else
            value.nil? ? true : value
          end
          Ergane.logger.debug "Setting switches[#{o.label}] = #{value.inspect}"
          switches[o.label] = value
        end
      end
    end

    private

    def initialize(label, *chain)
      super()
      @chain = chain
      @label = label
      @switch_definitions = {}
      @requirement_options = {
        inherit: true
      }
      @run_options = {
        inherit: true
      }
      @switch_parser = OptionParser.new
    end

    class DSL
      attr_reader :config

      def initialize
        @config = {
          switch_definitions: {},
          run_block: nil,
          requirements_block: nil
        }
      end

      def method_missing(k, v)
        @config[k] = v
      end

      def switches(inherit: true, drop: [], &block)
        def option(label, short: nil, kind: nil, description: nil, default: nil, &block)
          label, argument = case label
            when Hash
              [label.keys.first, "=#{label.values.first}"]
            else
              [label, nil]
            end
          warn "Warning! #{label.inspect} option is being redefined.".red if @config[:switch_definitions][label]
          @config[:switch_definitions][label] = SwitchDefinition.new(label, argument: argument, short: short, kind: kind, description: description, default: default, &block)
        end
        block.call if block_given?
        @config[:switch_definitions]
      end

      def requirements(options, &block)
        @config[:requirements_block] = block
      end

      def run(&block)
        # puts "setting run_block"
        @config[:run_block] = block
      end
    end
  end
end
