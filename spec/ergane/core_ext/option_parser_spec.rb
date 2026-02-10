# frozen_string_literal: true

RSpec.describe "OptionParser#order_recognized!" do
  it "parses recognized options" do
    parser = OptionParser.new
    result = {}
    parser.on("--verbose") { result[:verbose] = true }

    args = ["--verbose", "command"]
    parser.order_recognized!(args)

    expect(result[:verbose]).to be true
    expect(args).to eq(["command"])
  end

  it "leaves unrecognized options in args" do
    parser = OptionParser.new
    parser.on("--verbose") { }

    args = ["--unknown", "--verbose", "command"]
    parser.order_recognized!(args)

    expect(args).to include("--unknown")
    expect(args).to include("command")
  end

  it "handles no options" do
    parser = OptionParser.new
    args = ["deploy", "staging"]
    parser.order_recognized!(args)

    expect(args).to eq(["deploy", "staging"])
  end

  it "handles mixed recognized and unrecognized" do
    parser = OptionParser.new
    result = {}
    parser.on("--env VALUE") { |v| result[:env] = v }

    args = ["--env", "prod", "--debug", "deploy"]
    parser.order_recognized!(args)

    expect(result[:env]).to eq("prod")
    expect(args).to include("--debug")
    expect(args).to include("deploy")
  end
end
