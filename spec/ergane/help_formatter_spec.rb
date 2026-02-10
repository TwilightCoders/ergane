# frozen_string_literal: true

RSpec.describe Ergane::HelpFormatter do
  let(:cmd_class) do
    Class.new(Ergane::Command) do
      self.command_name = :deploy
      description "Deploy the application"
      option :env, String, short: :e, description: "Target environment", default: "staging"
      flag :force, short: :f, description: "Force deploy"
      argument :target, description: "Deploy target"
    end
  end

  let(:formatter) { Ergane::HelpFormatter.new(cmd_class) }

  describe "#format" do
    let(:output) { formatter.format }

    it "includes the description" do
      expect(output).to include("Deploy the application")
    end

    it "includes usage line" do
      expect(output.uncolorize).to include("Usage:")
    end

    it "includes the command name in usage" do
      expect(output.uncolorize).to include("deploy")
    end

    it "includes option signatures" do
      expect(output.uncolorize).to include("--env=VALUE")
      expect(output.uncolorize).to include("-e,")
    end

    it "includes flag signatures" do
      expect(output.uncolorize).to include("--force")
      expect(output.uncolorize).to include("-f,")
    end

    it "includes option descriptions" do
      expect(output).to include("Target environment")
      expect(output).to include("Force deploy")
    end

    it "includes default values" do
      expect(output.uncolorize).to include("(default: staging)")
    end

    it "includes argument section" do
      expect(output.uncolorize).to include("target")
      expect(output.uncolorize).to include("Deploy target")
    end
  end

  describe "with subcommands" do
    let(:parent) do
      Class.new(Ergane::Command) do
        self.command_name = :app
        description "My CLI app"

        command :deploy do
          description "Deploy the app"
        end

        command :status do
          description "Check status"
        end
      end
    end

    let(:output) { Ergane::HelpFormatter.new(parent).format }

    it "includes subcommands section" do
      expect(output.uncolorize).to include("Subcommands:")
    end

    it "lists each subcommand" do
      expect(output.uncolorize).to include("deploy")
      expect(output.uncolorize).to include("status")
    end

    it "includes subcommand descriptions" do
      expect(output).to include("Deploy the app")
      expect(output).to include("Check status")
    end
  end

  describe "with version (Tool)" do
    let(:tool) do
      Class.new(Ergane::Tool) do
        tool_name :mytool
        version "1.2.3"
        description "A great tool"
      end
    end

    let(:output) { Ergane::HelpFormatter.new(tool).format }

    it "includes version" do
      expect(output.uncolorize).to include("1.2.3")
    end
  end

  describe "command_path" do
    let(:output) { Ergane::HelpFormatter.new(cmd_class, command_path: ["app", "deploy"]).format }

    it "uses command_path in usage line" do
      expect(output.uncolorize).to include("app deploy")
    end
  end
end
