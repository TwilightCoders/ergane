# frozen_string_literal: true

RSpec.describe "Help and version flags" do
  let(:tool_class) do
    Class.new(Ergane::Tool) do
      tool_name :mytool
      version "3.0.0"
      description "Integration test tool"

      command :deploy do
        description "Deploy things"
        option :env, String, short: :e, description: "Target env"
        flag :force, short: :f

        run { "deployed" }
      end

      command :status do
        description "Check status"
        run { "ok" }
      end
    end
  end

  describe "--help at tool level" do
    it "prints help and does not execute" do
      expect { tool_class.start(["--help"]) }.to output(/Subcommands/).to_stdout
    end

    it "includes tool description" do
      expect { tool_class.start(["--help"]) }.to output(/Integration test tool/).to_stdout
    end

    it "includes version" do
      expect { tool_class.start(["--help"]) }.to output(/3\.0\.0/).to_stdout
    end
  end

  describe "--help on a subcommand" do
    it "prints subcommand help" do
      expect { tool_class.start(["deploy", "--help"]) }.to output(/--env/).to_stdout
    end

    it "includes the subcommand description" do
      expect { tool_class.start(["deploy", "--help"]) }.to output(/Deploy things/).to_stdout
    end
  end

  describe "--version" do
    it "prints the version" do
      expect { tool_class.start(["--version"]) }.to output(/mytool 3\.0\.0/).to_stdout
    end
  end

  describe "no subcommand given" do
    it "shows help when a tool has subcommands" do
      expect { tool_class.start([]) }.to output(/Subcommands/).to_stdout
    end
  end
end
