require 'gem-checkout/spec'

RSpec.describe Gem::Checkout::Spec::Remote::Metadata do
  let(:spec) { instance_double(Gem::Specification) }
  let(:mdata) { { 'foo' => 'baz' } }

  subject { described_class.new(mdata, nil) }

  describe "convenience methods" do
    context "with a valid gem spec" do
      before do
        allow(spec).to receive(:homepage).and_return('http://foo/home')
      end

      specify { expect(subject.homepage).to eq(nil) }
      specify { expect(subject.source_code_uri).to be(nil) }
      specify { expect(subject.source_code_url).to be(nil) }
      specify { expect(subject.repository_uri).to be(nil) }
      specify { expect(subject.repository_url).to be(nil) }
      specify { expect(subject.project_uri).to be(nil) }
      specify { expect(subject.project_url).to be(nil) }

      specify { expect(subject.source_reference).to be(nil) }
      specify { expect(subject.commit).to be(nil) }
      specify { expect(subject.revision).to be(nil) }
    end
  end

  describe "#alternative" do
    it "returns the metadata" do
      expect(subject.alternative).to be(nil)
    end
  end
end

RSpec.describe Gem::Checkout::Spec::Remote do
  let(:name) { 'foo' }
  let(:version) { '1.2.3' }

  subject { described_class.new(name, version) }

  let(:spec) { instance_double(Gem::Specification) }

  # returned by Gem.versions
  let(:versions_data) do
    [
      {
        "number" => "1.2.3",
        "metadata" => { 'foo' => 'baz' },
      }
    ]
  end

  let(:gem_info) do
    {
      "version" => "2.3.4", # not used here
      "metadata" => { 'bar' => 'foo' },
      "project_uri" => 'https://rubygems/gems/foo',
      "source_code_uri" => 'https://github.com/foo/bar',
      "homepage_uri" => 'http://foo/home',
    }
  end

  before do
    allow(Gem::Specification).to receive(:find_by_name).with(name, version).and_return(spec)
    allow(Gems).to receive(:versions).and_return(versions_data)
    allow(Gems).to receive(:info).and_return(gem_info)

  end

  describe "convenience methods" do
    context "with a valid gem spec" do
      before do
        allow(spec).to receive(:homepage).and_return('http://foo/home')
      end

      specify { expect(subject.homepage).to eq('http://foo/home') }
      specify { expect(subject.version).to eq('1.2.3') }
      specify { expect(subject.source_code_uri).to be(nil) }
      specify { expect(subject.source_code_url).to be(nil) }
      specify { expect(subject.repository_uri).to be(nil) }
      specify { expect(subject.repository_url).to be(nil) }
      specify { expect(subject.project_uri).to be(nil) }
      specify { expect(subject.project_url).to be(nil) }

      specify { expect(subject.bug_tracker_uri).to be(nil) }
      specify { expect(subject.bug_tracker_url).to be(nil) }

      specify { expect(subject.source_reference).to be(nil) }
      specify { expect(subject.commit).to be(nil) }
      specify { expect(subject.revision).to be(nil) }
    end
  end

  describe "#alternative" do
    let(:metadata) { instance_double(described_class::Metadata) }
    let(:mdata) { { 'foo' => 'baz' } }

    let(:remote) { instance_double(Gem::Checkout::Spec::Remote) }

    before do
      allow(described_class::Metadata).to receive(:new).with(mdata, nil).and_return(metadata)
    end

    it "returns the metadata" do
      expect(subject.alternative).to be(metadata)
    end
  end
end

RSpec.describe Gem::Checkout::Spec::Local::Metadata do
  let(:spec) { instance_double(Gem::Specification) }
  let(:mdata) { { 'foo' => 'baz' } }
  let(:remote) { instance_double(Gem::Checkout::Spec::Remote) }

  subject { described_class.new(mdata, remote) }

  describe "convenience methods" do
    context "with a valid gem spec" do
      before do
        allow(spec).to receive(:homepage).and_return('http://foo/home')
      end

      specify { expect(subject.homepage).to eq(nil) }
      specify { expect(subject.source_code_uri).to be(nil) }
      specify { expect(subject.source_code_url).to be(nil) }
      specify { expect(subject.repository_uri).to be(nil) }
      specify { expect(subject.repository_url).to be(nil) }
      specify { expect(subject.project_uri).to be(nil) }
      specify { expect(subject.project_url).to be(nil) }

      specify { expect(subject.source_reference).to be(nil) }
      specify { expect(subject.commit).to be(nil) }
      specify { expect(subject.revision).to be(nil) }
    end
  end

  describe "#alternative" do
    it "returns the remote object" do
      expect(subject.alternative).to be(remote)
    end
  end
end


RSpec.describe Gem::Checkout::Spec::Local do
  let(:name) { 'foo' }
  let(:version) { '1.2.3' }

  let(:remote) { instance_double(Gem::Checkout::Spec::Remote) }

  subject { described_class.new(name, version, remote) }

  let(:spec) { instance_double(Gem::Specification) }

  before do
    allow(Gem::Specification).to receive(:find_by_name).with(name, version).and_return(spec)
  end

  describe "convenience methods" do
    context "with a valid gem spec" do
      before do
        allow(spec).to receive(:homepage).and_return('http://foo/home')
        allow(spec).to receive(:version).and_return('0.1.2')
      end

      specify { expect(subject.homepage).to eq('http://foo/home') }
      specify { expect(subject.version).to eq('0.1.2') }
      specify { expect(subject.source_code_uri).to be(nil) }
      specify { expect(subject.source_code_url).to be(nil) }
      specify { expect(subject.repository_uri).to be(nil) }
      specify { expect(subject.repository_url).to be(nil) }
      specify { expect(subject.project_uri).to be(nil) }
      specify { expect(subject.project_url).to be(nil) }

      specify { expect(subject.source_reference).to be(nil) }
      specify { expect(subject.commit).to be(nil) }
      specify { expect(subject.revision).to be(nil) }
    end
  end

  describe "#alternative" do
    let(:metadata) { instance_double(described_class::Metadata) }
    let(:mdata) { { 'foo': 'bar' } }

    let(:remote) { instance_double(Gem::Checkout::Spec::Remote) }

    before do
      allow(described_class::Metadata).to receive(:new).with(mdata, remote).and_return(metadata)
      allow(spec).to receive(:metadata).and_return(mdata)
      allow(Gem::Checkout::Spec::Remote).to receive(:new).with(name, version).and_return(remote)
    end

    it "returns the metadata" do
      expect(subject.alternative).to be(metadata)
    end
  end
end

RSpec.describe Gem::Checkout::Spec do
  describe '.info' do
    let(:name) { 'foo' }
    let(:version) { '1.2.3' }

    let(:local) { instance_double(described_class::Local) }
    let(:remote) { instance_double(described_class::Remote) }

    subject { described_class }

    before do
      allow(described_class::Local).to receive(:new) do |*args|
        fail "stub called: Local.new(#{args.map(&:inspect) * ','})"
      end

      # always called
      allow(described_class::Remote).to receive(:new).and_return(remote)
    end

    context "when local spec is available" do
      before do
        allow(described_class::Local).to receive(:new).with(name, version, remote).and_return(local)
      end

      it "uses a local spec" do
        expect(subject.info(name, version)).to be(local)
      end
    end

    context "when local spec is not available" do
      before do
        allow(described_class::Local).to receive(:new).and_raise(Gem::LoadError)
      end

      context "when a remote spec is available" do
        before do
          allow(described_class::Remote).to receive(:new).with(name, version).and_return(remote)
        end

        it "uses a remote spec" do
          expect(subject.info(name, version)).to be(remote)
        end
      end

      context "when a remote spec is not available" do
        before do
          allow(described_class::Remote).to receive(:new).and_raise(described_class::Remote::Error::NoSuchGem)
        end

        it "fails" do
          expect { subject.info(name, version) }.
            to raise_error(described_class::Error::NoSuchGem)
        end
      end
    end
  end
end
