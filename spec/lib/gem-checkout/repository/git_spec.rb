require 'gem-checkout/repository/git'

RSpec.describe Gem::Checkout::Repository::Git do
  let(:uri) { URI.parse('https://github.com/foo/foo.git') }
  let(:process) { Gem::Checkout::Process }

  subject { described_class.new(uri) }

  before do
    allow(process).to receive(:run) do |*args|
      fail "stub called: Process.run(#{args.map(&:inspect) * ','})"
    end

    allow(process).to receive(:capture) do |*args|
      fail "stub called: Process.capture(#{args.map(&:inspect) * ','})"
    end
  end

  describe '#clone' do
    let(:options) { { directory: 'bar' } }

    context "when cloning succeeds" do
      before do
        allow(process).to receive(:run)
      end

      it "clones to given directory" do
        expect(process).to receive(:run).with('git', 'clone', uri.to_s, 'bar')
        subject.clone(options)
      end
    end

    context "when cloning fails" do
      before do
        allow(process).to receive(:run).and_raise(process::Error)
      end

      it "raises an error" do
        expect do
          subject.clone(options)
        end.to raise_error(
          described_class::Error::CloneFailed,
          /Failed to clone #{uri}/
        )
      end
    end
  end

  describe '#checkout' do
    let(:ref) { 'a0b3de8f' }

    context "when checking out succeeds" do
      before do
        allow(process).to receive(:run)
      end

      it "checks out by reference" do
        expect(process).to receive(:run).with('git', 'checkout', ref)
        subject.checkout(ref)
      end
    end

    context "when checking out fails" do
      before do
        allow(process).to receive(:run).and_raise(process::Error)
      end

      it "raises an error" do
        expect do
          subject.checkout(ref)
        end.to raise_error(
          described_class::Error::CheckoutFailed,
          /Failed to checkout #{ref}/
        )
      end
    end
  end

  describe '#get_tag_ref' do
    let(:tag) { 'v0.1.2' }
    let(:expected_ref) { '3cc04ad0a1866423aaf0bf1820a2f7105abd7a62' }
    let(:output) { "3cc04ad0a1866423aaf0bf1820a2f7105abd7a62\trefs/tags/v0.1.2\n" }

    context "when the tag exists" do
      before do
        allow(process).to receive(:capture).and_return(output)
      end

      it "returns the tag's hash" do
        expect(subject.get_tag_ref(tag)).to eq(expected_ref)
      end
    end

    context "when the tag does not exist" do
      let(:tag) { 'v1.0.0' }

      before do
        allow(process).to receive(:capture).and_return(output)
      end

      it "raises an error" do
        expect do
          subject.get_tag_ref(tag)
        end.to raise_error(Gem::Checkout::Repository::Git::Error::SingleTagNotFound)
      end
    end

    context "when something fails" do
      before do
        allow(process).to receive(:capture).and_raise(process::Error)
      end

      it "raises an error" do
        expect do
          subject.get_tag_ref(tag)
        end.to raise_error(Gem::Checkout::Repository::Git::Error::FailedToFetchTags)
      end
    end
  end
end
