require 'gem-checkout/source'

RSpec.describe Gem::Checkout::Source do
  let(:repo) { instance_double(Gem::Checkout::Repository::GitHub) }
  let(:git_url) { 'https://github.com/foo/bar' }
  let(:git_uri) { URI.parse(git_url) }
  let(:ref) { '02198abc98e9b9' }


  let(:name) { 'foo' }
  let(:version) { '1.2.3' }
  let(:args) { [name, version] }

  subject { described_class.new(*args) }

  let(:local) { instance_double(Gem::Checkout::Spec::Local) }
  let(:remote) { instance_double(Gem::Checkout::Spec::Remote) }

  before do
    allow(Gem::Checkout::Repository::GitHub).to receive(:new).with(git_uri).and_return(repo)

    allow(Gem::Checkout::Spec::Local).to receive(:new) do |*args|
      fail "stub called: Local.new(#{args.map(&:inspect) * ','})"
    end

    # always created
    allow(Gem::Checkout::Spec::Remote).to receive(:new).and_return(remote)
  end

  describe '#initialize' do
    context "with valid local information" do
      let(:github) { instance_double(Gem::Checkout::Repository::GitHub) }

      before do
        allow(Gem::Checkout::Spec).to receive(:info).with(name, version).and_return(local)
        allow(local).to receive(:version).and_return(version)

        url = 'https://github.com/foo/bar'
        allow(local).to receive(:source_code_uri).and_return(nil)
        allow(local).to receive(:source_code_url).and_return(nil)
        allow(local).to receive(:repository_uri).and_return(nil)
        allow(local).to receive(:repository_url).and_return(nil)
        allow(local).to receive(:project_uri).and_return(nil)
        allow(local).to receive(:project_url).and_return(nil)
        allow(local).to receive(:homepage).and_return(url)

        allow(local).to receive(:source_reference).and_return(ref)

        #allow(local).to receive(:commit).and_return(nil)
        #allow(local).to receive(:revision).and_return(nil)

        allow(local).to receive(:alternative).and_return(nil)
        allow(Gem::Checkout::Repository::GitHub).to receive(:new).with(url).and_return(github)
      end

      it "sets the repository" do
        expect(subject.repository).to be(repo)
      end

      it "sets the source_reference" do
        expect(subject.source_reference).to eq(ref)
      end
    end
  end

  describe '#version' do
    before do
      allow(local).to receive(:source_code_uri).and_return(git_url)
      allow(local).to receive(:source_reference).and_return(ref)
    end

    context "when provided" do
      before do
        allow(Gem::Checkout::Spec).to receive(:info).with(name, version).and_return(local)
        allow(local).to receive(:version).and_return(version)
      end

      it "matches provided" do
        expect(subject.version).to eq(version)
      end
    end

    context "when not provided" do
      let(:args) { [name] }

      before do
        allow(Gem::Checkout::Spec).to receive(:info).with(name, nil).and_return(local)
        allow(local).to receive(:version).and_return('2.0.0')
      end

      it "matches latest" do
        expect(subject.version).to eq('2.0.0')
      end
    end
  end
end
