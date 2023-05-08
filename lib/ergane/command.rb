module Ergane

  class Hashall < Hash
    def initialize
      super
      self.default_proc = -> (h, k) { h[k] = Hashall.new }
    end
  end

  class Command < Hashall
    attr_reader :label
    attr_reader :description
    attr_reader :options
    attr_reader :command
    attr_reader :commands

    def pretty_print(q)
      q.text self.class.name
      q.text "\n\tCommands:"
      q.group(1, " {", "}") do
        self.each_pair do |key, value|
          q.breakable
          q.text "#{key}: #{value}"
        end
      end
    end

    def run(*args)
      if command
        instance_exec(*args, &command)
      else
        puts "no"
      end
    end

    def self.define(label, chain: [], &block)
      new.tap do |c|
        c.define(label, chain: chain, &block)
      end
    end

    def define(label, chain: [], &block)
      @label = label
      dsl_parse(&block)
    end

    protected

    def dsl_parse(&block)
      dsl = DSL.new.tap do |dsl|
        dsl.instance_eval(&block)
      end
      @options.merge!(dsl.config[:options])
      @command = dsl.config[:command]
    end

    private

    def initialize
      super
      @options = Hashall.new
    end

    class DSL
      attr_reader :config

      def initialize
        @config = Hashall.new
      end

      def method_missing(k, v)
        @config[k] = v
      end

      def options(inherit: true, drop: [], &block)
        def option(label, kind, description, default = nil)
          puts "Creating option #{label}"
          @config[:options][label] = kind
        end
        block.call if block_given?
        @config[:options]
      end

      def run(&block)
        puts "setting command"
        @config[:command] = block
      end
    end
  end
end
