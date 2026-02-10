# frozen_string_literal: true

RSpec.describe Ergane::CommandNotFound do
  it "includes the unknown command name" do
    error = Ergane::CommandNotFound.new("deplyo", available: [:deploy, :status])
    expect(error.message).to include("deplyo")
  end

  it "suggests a close match" do
    error = Ergane::CommandNotFound.new("deplyo", available: [:deploy, :status])
    expect(error.message).to include("Did you mean 'deploy'?")
  end

  it "lists available commands" do
    error = Ergane::CommandNotFound.new("foo", available: [:deploy, :status])
    expect(error.message).to include("deploy, status")
  end

  it "does not suggest when nothing is close" do
    error = Ergane::CommandNotFound.new("xyzzy", available: [:deploy, :status])
    expect(error.message).not_to include("Did you mean")
  end

  it "works with no available commands" do
    error = Ergane::CommandNotFound.new("foo")
    expect(error.message).to include("Unknown command: 'foo'")
  end
end
