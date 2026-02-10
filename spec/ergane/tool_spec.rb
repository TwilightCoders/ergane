# frozen_string_literal: true

RSpec.describe Ergane::Tool do
  let(:tool_class) do
    Class.new(Ergane::Tool) do
      tool_name :mytool
      version "1.0.0"
      description "A test tool"

      command :greet do
        description "Say hello"
        option :name, String, short: :n, default: "world"

        run do |*_args|
          "Hello #{options[:name]}!"
        end
      end

      command :ping do
        description "Ping pong"

        run { "pong" }
      end
    end
  end

  describe "class-level DSL" do
    it "stores the tool name" do
      expect(tool_class.tool_name).to eq(:mytool)
    end

    it "stores the version" do
      expect(tool_class.version).to eq("1.0.0")
    end

    it "stores the description" do
      expect(tool_class.description).to eq("A test tool")
    end

    it "registers block-based subcommands" do
      expect(tool_class.subcommands).to have_key(:greet)
      expect(tool_class.subcommands).to have_key(:ping)
    end
  end

  describe ".start" do
    it "resolves and executes a subcommand" do
      result = tool_class.start(["greet", "-n", "Dale"])
      expect(result).to eq("Hello Dale!")
    end

    it "passes default options" do
      result = tool_class.start(["greet"])
      expect(result).to eq("Hello world!")
    end

    it "executes simple commands" do
      result = tool_class.start(["ping"])
      expect(result).to eq("pong")
    end
  end

  describe "auto-created command base" do
    it "creates a ::Command constant on the tool" do
      expect(tool_class.const_defined?(:Command)).to be true
    end

    it "makes the command base a subclass of Ergane::Command" do
      expect(tool_class::Command.superclass).to eq(Ergane::Command)
    end

    it "makes the command base abstract" do
      expect(tool_class::Command.abstract_class?).to be true
    end

    it "has a tool reference" do
      expect(tool_class::Command.tool).to eq(tool_class)
    end

    it "block-based commands inherit from the command base, not the tool" do
      greet = tool_class.subcommands[:greet]
      expect(greet.ancestors).to include(tool_class::Command)
      expect(greet.ancestors).not_to include(Ergane::Tool)
    end
  end

  describe "class-based subcommands via command base" do
    let(:tool_with_class_commands) do
      t = Class.new(Ergane::Tool) do
        tool_name :app
        version "2.0.0"
      end

      Class.new(t::Command) do
        self.command_name = :deploy
        option :env, String, default: "staging"

        define_method(:run) do |*args|
          { env: options[:env], targets: args }
        end
      end

      t
    end

    it "resolves class-based subcommands via start" do
      result = tool_with_class_commands.start(["deploy", "--env", "production", "web"])
      expect(result).to eq({ env: "production", targets: ["web"] })
    end

    it "registers under the tool, not the command base" do
      expect(tool_with_class_commands.subcommands).to have_key(:deploy)
    end

    it "does not pollute the command base's subcommands" do
      # The command base is abstract; commands register on the tool
      expect(tool_with_class_commands::Command.subcommands).to be_empty
    end
  end

  describe "custom command_class" do
    let(:custom_base) do
      Class.new(Ergane::Command) do
        self.abstract_class = true
        flag :verbose, short: :v, description: "Verbose output"
      end
    end

    let(:tool_with_custom_base) do
      base = custom_base
      t = Class.new(Ergane::Tool) do
        tool_name :app
        version "1.0.0"
        command_class base
      end

      Class.new(base) do
        self.command_name = :deploy

        define_method(:run) do |*args|
          { verbose: options[:verbose], targets: args }
        end
      end

      t
    end

    it "uses the custom command base" do
      expect(tool_with_custom_base.command_class).to eq(custom_base)
    end

    it "inherits options from the custom base" do
      result = tool_with_custom_base.start(["deploy", "--verbose", "web"])
      expect(result).to eq({ verbose: true, targets: ["web"] })
    end
  end

  describe "Tool is abstract" do
    it "does not register Tool subclasses as subcommands of Command" do
      expect(Ergane::Command.subcommands).not_to have_key(:mytool)
    end
  end
end
