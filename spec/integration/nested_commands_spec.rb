# frozen_string_literal: true

RSpec.describe "Nested command resolution" do
  let(:tool_class) do
    t = Class.new(Ergane::Tool) do
      tool_name :app
      version "1.0.0"

      command :server do
        description "Server management"

        command :start do
          description "Start the server"
          option :port, String, short: :p, default: "3000"

          run { "started on port #{options[:port]}" }
        end

        command :stop do
          description "Stop the server"
          run { "stopped" }
        end
      end
    end
    t
  end

  it "resolves two levels deep" do
    result = tool_class.start(["server", "start"])
    expect(result).to eq("started on port 3000")
  end

  it "passes options through nested resolution" do
    result = tool_class.start(["server", "start", "-p", "8080"])
    expect(result).to eq("started on port 8080")
  end

  it "resolves sibling commands" do
    result = tool_class.start(["server", "stop"])
    expect(result).to eq("stopped")
  end

  it "shows help for intermediate commands" do
    expect { tool_class.start(["server", "--help"]) }.to output(/start/).to_stdout
    expect { tool_class.start(["server", "--help"]) }.to output(/stop/).to_stdout
  end
end
