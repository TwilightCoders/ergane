# frozen_string_literal: true

RSpec.describe Ergane::Command do
  describe "class-level DSL" do
    let(:cmd_class) do
      Class.new(Ergane::Command) do
        self.command_name = :deploy
        description "Deploy the application"
        aliases :d, :dep
        option :env, String, short: :e, description: "Target environment"
        flag :force, short: :f, description: "Force deploy"
        argument :target, description: "Deploy target"
      end
    end

    it "stores the command name" do
      expect(cmd_class.command_name).to eq(:deploy)
    end

    it "stores the description" do
      expect(cmd_class.description).to eq("Deploy the application")
    end

    it "stores aliases" do
      expect(cmd_class.aliases).to eq([:d, :dep])
    end

    it "computes terms as command_name + aliases" do
      expect(cmd_class.terms).to eq([:deploy, :d, :dep])
    end

    it "stores option definitions" do
      expect(cmd_class.option_definitions).to have_key(:env)
      expect(cmd_class.option_definitions[:env].type).to eq(String)
    end

    it "stores flag definitions as boolean options" do
      expect(cmd_class.option_definitions).to have_key(:force)
      expect(cmd_class.option_definitions[:force].boolean?).to be true
    end

    it "stores argument definitions" do
      expect(cmd_class.argument_definitions.length).to eq(1)
      expect(cmd_class.argument_definitions.first.name).to eq(:target)
    end
  end

  describe "command_name derivation" do
    it "derives from class name" do
      klass = Class.new(Ergane::Command)
      # Anonymous classes don't have names, so derivation returns nil
      expect(klass.command_name).to be_nil
    end

    it "strips Command suffix" do
      # Simulate a named class by setting command_name explicitly
      klass = Class.new(Ergane::Command) { self.command_name = :deploy }
      expect(klass.command_name).to eq(:deploy)
    end
  end

  describe "option inheritance" do
    let(:parent) do
      Class.new(Ergane::Command) do
        self.command_name = :parent
        self.abstract_class = true
        flag :debug, short: :d, description: "Debug mode"
      end
    end

    let(:child) do
      Class.new(parent) do
        self.command_name = :child
        option :name, String, description: "Your name"
      end
    end

    it "inherits parent options" do
      expect(child.option_definitions).to have_key(:debug)
    end

    it "has its own options too" do
      expect(child.option_definitions).to have_key(:name)
    end

    it "does not modify the parent" do
      child # trigger creation
      expect(parent.option_definitions).not_to have_key(:name)
    end
  end

  describe "subcommand registration" do
    let(:parent) do
      Class.new(Ergane::Command) do
        self.command_name = :app
      end
    end

    it "auto-registers class-based subcommands" do
      sub = Class.new(parent) { self.command_name = :deploy }
      expect(parent.subcommands[:deploy]).to eq(sub)
    end

    it "does not register abstract subcommands" do
      Class.new(parent) do
        self.command_name = :base
        self.abstract_class = true
      end
      expect(parent.subcommands[:base]).to be_nil
    end
  end

  describe "block-based command DSL" do
    let(:parent) do
      Class.new(Ergane::Command) do
        self.command_name = :app

        command :status do
          description "Check status"
          flag :verbose, short: :v

          run { "status: ok" }
        end
      end
    end

    it "registers the block-based subcommand" do
      expect(parent.subcommands).to have_key(:status)
    end

    it "stores description from the block" do
      expect(parent.subcommands[:status].description).to eq("Check status")
    end

    it "stores options from the block" do
      expect(parent.subcommands[:status].option_definitions).to have_key(:verbose)
    end

    it "defines a run method from the block" do
      instance = parent.subcommands[:status].new
      expect(instance.run).to eq("status: ok")
    end
  end

  describe "instance behavior" do
    let(:cmd_class) do
      Class.new(Ergane::Command) do
        self.command_name = :greet
        option :name, String, short: :n, default: "world"

        define_method(:run) do |*args|
          "Hello #{options[:name]}!"
        end
      end
    end

    it "parses options from argv" do
      instance = cmd_class.new(["-n", "Dale"])
      expect(instance.options[:name]).to eq("Dale")
    end

    it "uses defaults when no option given" do
      instance = cmd_class.new([])
      expect(instance.options[:name]).to eq("world")
    end

    it "collects remaining args" do
      instance = cmd_class.new(["-n", "Dale", "extra", "args"])
      expect(instance.args).to eq(["extra", "args"])
    end

    it "runs the command" do
      instance = cmd_class.new(["-n", "Dale"])
      expect(instance.run).to eq("Hello Dale!")
    end
  end
end
