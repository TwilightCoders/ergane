# frozen_string_literal: true

RSpec.describe Ergane::Concerns::Inheritance do
  let(:base) do
    Class.new(Ergane::Command) do
      self.command_name = :base
      self.abstract_class = true
    end
  end

  let(:concrete) do
    Class.new(base) do
      self.command_name = :concrete
    end
  end

  let(:leaf) do
    Class.new(concrete) do
      self.command_name = :leaf
    end
  end

  describe ".abstract_class?" do
    it "is false by default" do
      klass = Class.new(Ergane::Command) { self.command_name = :test }
      expect(klass.abstract_class?).to be false
    end

    it "is true when set" do
      expect(base.abstract_class?).to be true
    end
  end

  describe ".base_class" do
    it "returns the first non-abstract class below Command" do
      expect(concrete.base_class).to eq(concrete)
    end

    it "skips abstract classes in the hierarchy" do
      expect(leaf.base_class).to eq(concrete)
    end

    it "raises if not descending from Command" do
      klass = Class.new
      klass.extend(Ergane::Concerns::Inheritance::ClassMethods)
      expect { klass.base_class }.to raise_error(Ergane::Error)
    end
  end
end
