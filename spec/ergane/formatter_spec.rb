# frozen_string_literal: true

RSpec.describe Ergane::Formatter do
  describe ".confirm?" do
    before { allow($stderr).to receive(:print) }

    it "prompts on stderr" do
      allow($stdin).to receive(:tty?).and_return(false)
      described_class.confirm?("Proceed?")
      expect($stderr).to have_received(:print).with("Proceed? [y/N] ")
    end

    it "returns false when stdin is not a TTY" do
      allow($stdin).to receive(:tty?).and_return(false)
      expect(described_class.confirm?("Proceed?")).to be false
    end

    context "when stdin is a TTY" do
      before { allow($stdin).to receive(:tty?).and_return(true) }

      it "returns true for 'y'" do
        allow($stdin).to receive(:gets).and_return("y\n")
        expect(described_class.confirm?("Proceed?")).to be true
      end

      it "returns true for 'yes' regardless of case" do
        allow($stdin).to receive(:gets).and_return("YES\n")
        expect(described_class.confirm?("Proceed?")).to be true
      end

      it "returns false for 'n'" do
        allow($stdin).to receive(:gets).and_return("n\n")
        expect(described_class.confirm?("Proceed?")).to be_falsey
      end

      it "returns false for an empty answer" do
        allow($stdin).to receive(:gets).and_return("\n")
        expect(described_class.confirm?("Proceed?")).to be_falsey
      end

      it "returns false on EOF (nil)" do
        allow($stdin).to receive(:gets).and_return(nil)
        expect(described_class.confirm?("Proceed?")).to be_falsey
      end
    end
  end

  describe ".time_ago" do
    it "returns 'just now' under a minute" do
      expect(described_class.time_ago(Time.now - 30)).to eq("just now")
    end

    it "returns minutes under an hour" do
      expect(described_class.time_ago(Time.now - 150)).to eq("2m ago")
    end

    it "returns hours under a day" do
      expect(described_class.time_ago(Time.now - 7200)).to eq("2h ago")
    end

    it "returns days beyond a day" do
      expect(described_class.time_ago(Time.now - (3 * 86400))).to eq("3d ago")
    end
  end
end
