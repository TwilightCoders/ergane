# frozen_string_literal: true

RSpec.describe Ergane::Runner do
  let(:root) do
    Class.new(Ergane::Command) do
      self.command_name = :app
    end
  end

  let!(:deploy) do
    parent = root
    Class.new(parent) do
      self.command_name = :deploy
      option :env, String, short: :e, default: "staging"

      define_method(:run) do |*args|
        { command: :deploy, env: options[:env], args: args }
      end
    end
  end

  let!(:status) do
    parent = root
    Class.new(parent) do
      self.command_name = :status
      flag :verbose, short: :v

      define_method(:run) do |*args|
        { command: :status, verbose: options[:verbose] }
      end
    end
  end

  describe "#execute" do
    it "resolves a top-level subcommand" do
      result = Ergane::Runner.new(root, ["deploy"]).execute
      expect(result[:command]).to eq(:deploy)
    end

    it "passes options to the resolved command" do
      result = Ergane::Runner.new(root, ["deploy", "-e", "production"]).execute
      expect(result[:env]).to eq("production")
    end

    it "passes remaining positional args" do
      result = Ergane::Runner.new(root, ["deploy", "web", "api"]).execute
      expect(result[:args]).to eq(["web", "api"])
    end

    it "resolves flags on subcommands" do
      result = Ergane::Runner.new(root, ["status", "--verbose"]).execute
      expect(result[:verbose]).to be true
    end

    it "uses default option values" do
      result = Ergane::Runner.new(root, ["deploy"]).execute
      expect(result[:env]).to eq("staging")
    end
  end

  describe "nested subcommands" do
    let!(:deploy_web) do
      parent = deploy
      Class.new(parent) do
        self.command_name = :web

        define_method(:run) do |*args|
          { command: :deploy_web, args: args }
        end
      end
    end

    it "resolves nested subcommands" do
      result = Ergane::Runner.new(root, ["deploy", "web"]).execute
      expect(result[:command]).to eq(:deploy_web)
    end

    it "passes args through nested resolution" do
      result = Ergane::Runner.new(root, ["deploy", "web", "server1"]).execute
      expect(result[:args]).to eq(["server1"])
    end
  end

  describe "unknown tokens" do
    it "treats unknown tokens as positional args for the current command" do
      result = Ergane::Runner.new(root, ["deploy", "unknown_thing"]).execute
      expect(result[:args]).to eq(["unknown_thing"])
    end
  end
end
