# frozen_string_literal: true

RSpec.describe Ergane::PathRegistry do
  subject(:registry) { described_class.new }

  describe "#abbreviate" do
    it "returns the path unchanged when nothing matches" do
      expect(registry.abbreviate("/etc/hosts")).to eq("/etc/hosts")
    end

    it "collapses a registered prefix to its label" do
      registry.register("/var/data", "@data")
      expect(registry.abbreviate("/var/data/cache/x")).to eq("@data/cache/x")
    end

    it "collapses an exact-match prefix to just the label" do
      registry.register("/var/data", "@data")
      expect(registry.abbreviate("/var/data")).to eq("@data")
    end

    it "expands ~ when registering so $HOME collapses" do
      registry.register("~", "~")
      expect(registry.abbreviate("#{File.expand_path('~')}/projects")).to eq("~/projects")
    end

    it "expands ~-relative input before matching" do
      registry.register("~", "~")
      expect(registry.abbreviate("~/projects")).to eq("~/projects")
    end

    it "only matches at a path boundary" do
      registry.register("/home/user", "~")
      expect(registry.abbreviate("/home/username/file")).to eq("/home/username/file")
    end

    it "prefers the longest matching prefix" do
      registry.register("/home/user", "~")
      registry.register("/home/user/Workspace", "@ws")
      expect(registry.abbreviate("/home/user/Workspace/repo")).to eq("@ws/repo")
    end

    it "accepts non-string paths" do
      registry.register("/var/data", "@data")
      expect(registry.abbreviate(Pathname.new("/var/data/x"))).to eq("@data/x")
    end
  end

  describe "#register" do
    it "is chainable" do
      expect(registry.register("/a", "@a")).to be(registry)
    end

    it "replaces the label when re-registering the same prefix" do
      registry.register("/var/data", "@old")
      registry.register("/var/data", "@new")
      expect(registry.abbreviate("/var/data/x")).to eq("@new/x")
    end
  end

  describe "#clear" do
    it "removes every substitution" do
      registry.register("/var/data", "@data")
      registry.clear
      expect(registry.abbreviate("/var/data/x")).to eq("/var/data/x")
    end

    it "is chainable" do
      expect(registry.clear).to be(registry)
    end
  end
end
