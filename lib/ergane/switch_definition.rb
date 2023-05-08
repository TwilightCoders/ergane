module Ergane
  class NamedBlock
    def self.new(*args, &block)
      Class.new do
        args.each do |arg|
          attr_reader arg.to_sym
        end

        def initialize(label, args)
          @label = label.to_sym
          args.each do |arg, value|
            instance_variable_set("@#{args}", value)
          end
        end
      end
    end
    private :initialize
  end

  class SwitchDefinition < NamedBlock.new(:short, :kind, :argument, :description, :default)
    attr_reader :label
    attr_reader :short
    attr_reader :kind
    attr_reader :argument
    attr_reader :description
    attr_reader :default
    attr_reader :run_block

    def initialize(label, short: nil, argument: nil, kind: nil, description: nil, default: nil, &block)
      @label, @short, @argument, @kind, @description, @default = label.to_sym, short, argument, kind, description, default
      @run_block = block if block_given?
    end

    def attach(option_parser, &block)
      flag_arg = argument ? "=#{argument}" : ""
      args = []
      args << "-#{short}#{flag_arg}" if short
      args << "--#{label.to_s.gsub(/_/, '-')}#{flag_arg}"
      args << kind if kind
      args << description if description

      option_parser.on(*args, Proc.new { |value|
        instance_exec(value, &block) if block_given?
        instance_exec(value, &run_block) if run_block
      })
    end

  end
end
