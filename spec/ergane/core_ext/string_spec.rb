# frozen_string_literal: true

RSpec.describe "String core extensions" do
  describe "#underscore" do
    it "converts CamelCase to snake_case" do
      expect("DeployCommand".underscore).to eq("deploy_command")
    end

    it "handles consecutive capitals" do
      expect("HTMLParser".underscore).to eq("html_parser")
    end

    it "converts :: to /" do
      expect("Ergane::Deploy".underscore).to eq("ergane/deploy")
    end

    it "handles single word" do
      expect("Deploy".underscore).to eq("deploy")
    end

    it "handles already underscored" do
      expect("deploy_command".underscore).to eq("deploy_command")
    end
  end

  describe "#demodulize" do
    it "strips module namespace" do
      expect("Ergane::Deploy".demodulize).to eq("Deploy")
    end

    it "strips deeply nested namespace" do
      expect("Ergane::DSL::CommandDSL".demodulize).to eq("CommandDSL")
    end

    it "returns itself when no namespace" do
      expect("Deploy".demodulize).to eq("Deploy")
    end
  end
end
