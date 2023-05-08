module Ergane
  class Option

    attr_reader :switch, :args, :block

    def initialize(switch, *args, &block)
      @switch = switch
      @args = args
      @block = block
    end

    def set(option_parser)
      option_parser.on(switch, *args, &block)
    end

    def rescope(klass)
      block = Proc.new do |db|
        klass.instance_exec(db, &option[:block])
      end
    end

    def require

    end

  end
end
