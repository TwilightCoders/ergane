# frozen_string_literal: true

RSpec.describe "Class-based command definition" do
  let(:tool_class) do
    t = Class.new(Ergane::Tool) do
      tool_name :app
      version "1.0.0"
    end

    # Define a class-based subcommand via the tool's command base
    Class.new(t::Command) do
      self.command_name = :deploy
      description "Deploy the application"
      option :env, String, short: :e, default: "staging"
      flag :verbose, short: :v

      define_method(:run) do |*targets|
        { env: options[:env], verbose: options[:verbose], targets: targets }
      end
    end

    t
  end

  it "registers the class-based command" do
    expect(tool_class.subcommands).to have_key(:deploy)
  end

  it "command is a Command, not a Tool" do
    deploy = tool_class.subcommands[:deploy]
    expect(deploy.ancestors).to include(Ergane::Command)
    expect(deploy.ancestors).not_to include(Ergane::Tool)
  end

  it "executes via start" do
    result = tool_class.start(["deploy", "-e", "production", "web", "api"])
    expect(result).to eq({ env: "production", verbose: false, targets: ["web", "api"] })
  end

  it "uses default values" do
    result = tool_class.start(["deploy"])
    expect(result[:env]).to eq("staging")
    expect(result[:verbose]).to be false
  end
end
