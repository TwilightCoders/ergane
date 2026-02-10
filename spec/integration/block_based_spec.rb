# frozen_string_literal: true

RSpec.describe "Block-based command definition" do
  let(:tool_class) do
    Class.new(Ergane::Tool) do
      tool_name :app
      version "1.0.0"

      command :greet do
        description "Greet someone"
        option :name, String, short: :n, default: "world"

        run { "Hello #{options[:name]}!" }
      end

      command :farewell, aliases: [:bye] do
        description "Say goodbye"
        option :name, String, short: :n, default: "world"

        run { "Goodbye #{options[:name]}!" }
      end
    end
  end

  it "registers block-based commands" do
    expect(tool_class.subcommands).to have_key(:greet)
    expect(tool_class.subcommands).to have_key(:farewell)
  end

  it "executes block-based commands" do
    result = tool_class.start(["greet", "-n", "Dale"])
    expect(result).to eq("Hello Dale!")
  end

  it "uses default option values" do
    result = tool_class.start(["greet"])
    expect(result).to eq("Hello world!")
  end

  it "stores aliases" do
    expect(tool_class.subcommands[:farewell].aliases).to eq([:bye])
  end

  it "stores description" do
    expect(tool_class.subcommands[:greet].description).to eq("Greet someone")
  end
end
