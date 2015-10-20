require 'gem-checkout/repository/git-hub'

RSpec.describe Gem::Checkout::Repository::GitHub do
  let(:uri) { URI.parse('https://github.com/foo/foo') }
  let(:git_uri) { URI.parse('https://github.com/foo/foo.git') }

  subject { described_class.new(uri) }

  let(:git) { instance_double(Gem::Checkout::Repository::Git) }

  before do
    allow(Gem::Checkout::Repository::Git).to receive(:new).with(git_uri).and_return(git)
  end

  describe '#initialize' do
    context 'with a valid GitHub repository page url' do
      let(:uri) { URI.parse('http://github.com/foo/bar?foo=bar&bar=baz#contributing') }
      let(:expected) { URI.parse('https://github.com/foo/bar.git') }

      it 'normalizes the url' do
        allow(Gem::Checkout::Repository::Git).to receive(:new).with(expected)
        subject
      end
    end

    context 'with a non GitHub url' do
      let(:uri) { URI.parse('https://example.com/foo/bar') }
      it 'fails' do
        expect { subject }.to raise_error(described_class::Error::BadURI::NotGitHub)
      end
    end

    context 'with an incomplete GitHub url' do
      let(:uri) { URI.parse('https://github.com/foo') }
      it 'fails' do
        expect { subject }.to raise_error(described_class::Error::BadURI::NoProjectName)
      end
    end
  end

  describe '#clone' do
    let(:options) { { directory: 'bar' } }

    context "when cloning succeeds" do
      before do
        allow(git).to receive(:clone)
      end

      it "clones to given directory" do
        expect(git).to receive(:clone).with(options)
        subject.clone(options)
      end
    end

    context "when cloning fails" do
      before do
        allow(git).to receive(:clone).and_raise(Gem::Checkout::Repository::Git::Error)
      end

      it "raises an error" do
        expect do
          subject.clone(options)
        end.to raise_error(Gem::Checkout::Repository::Git::Error)
      end
    end
  end

  describe '#checkout' do
    let(:ref) { 'a0b3de8f' }

    context "when checking out succeeds" do
      before do
        allow(git).to receive(:checkout)
      end

      it "checks out by reference" do
        expect(git).to receive(:checkout).with(ref)
        subject.checkout(ref)
      end
    end

    context "when checking out fails" do
      before do
        allow(git).to receive(:checkout).
          and_raise(Gem::Checkout::Repository::Git::Error)
      end

      it "raises an error" do
        expect do
          subject.checkout(ref)
        end.to raise_error(Gem::Checkout::Repository::Git::Error)
      end
    end
  end

  describe '#get_tag_ref' do
    let(:tag) { '0.1.2' }
    let(:expected_ref) { 'a0b3de8f' }

    context "when the tag exists" do
      before do
        allow(git).to receive(:get_tag_ref).and_return(expected_ref)
      end

      it "returns the tag's hash" do
        expect(subject.get_tag_ref(tag)).to eq(expected_ref)
      end
    end

    context "when the tag does not exist" do
      before do
        allow(git).to receive(:get_tag_ref).
          and_raise(Gem::Checkout::Repository::Git::Error)
      end

      it "raises an error" do
        expect do
          subject.get_tag_ref(tag)
        end.to raise_error(Gem::Checkout::Repository::Git::Error)
      end
    end

    context "when something fails" do
      before do
        allow(git).to receive(:get_tag_ref).
          and_raise(Gem::Checkout::Repository::Git::Error)
      end

      it "raises an error" do
        expect do
          subject.get_tag_ref(tag)
        end.to raise_error(Gem::Checkout::Repository::Git::Error)
      end
    end
  end
end
