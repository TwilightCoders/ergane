# frozen_string_literal: true

RSpec.describe "Object core extensions" do
  describe "#blank?" do
    it("nil is blank")    { expect(nil.blank?).to be true }
    it("false is blank")  { expect(false.blank?).to be true }
    it("true is not blank") { expect(true.blank?).to be false }
    it("0 is not blank")  { expect(0.blank?).to be false }
    it("empty string is blank") { expect("".blank?).to be true }
    it("whitespace is blank") { expect("  \n\t ".blank?).to be true }
    it("text is not blank") { expect("hello".blank?).to be false }
    it("empty array is blank") { expect([].blank?).to be true }
    it("non-empty array is not blank") { expect([1].blank?).to be false }
    it("empty hash is blank") { expect({}.blank?).to be true }
  end

  describe "#present?" do
    it("nil is not present")  { expect(nil.present?).to be false }
    it("text is present")     { expect("hello".present?).to be true }
    it("empty string is not") { expect("".present?).to be false }
  end

  describe "#try" do
    it "calls method if it exists" do
      expect("hello".try(:upcase)).to eq("HELLO")
    end

    it "returns nil if method does not exist" do
      expect("hello".try(:nonexistent_method)).to be_nil
    end

    it "returns nil on nil receiver" do
      expect(nil.try(:upcase)).to be_nil
    end

    it "passes arguments" do
      expect("hello world".try(:gsub, "world", "ruby")).to eq("hello ruby")
    end
  end
end
