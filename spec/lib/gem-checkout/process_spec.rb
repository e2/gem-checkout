require 'gem-checkout/process'
RSpec.describe Gem::Checkout::Process do
  let(:pid) { 1234 }
  let(:exit_code) { 0 }
  let(:status) { instance_double(Process::Status, exitstatus: exit_code) }

  let(:wait_result) { [pid, status] }

  before do
    allow(Kernel).to receive(:spawn).and_return(pid)
    allow(Process).to receive(:wait2).with(pid).and_return(wait_result)
  end

  describe '.run' do
    context "with a succeeding command" do
      let(:exit_code) { 0 }

      it "runs the command" do
        expect(Kernel).to receive(:spawn).with('foo', 'bar').and_return(pid)
        described_class.run('foo', 'bar')
      end
    end

    context "with a failing command" do
      let(:exit_code) { 123 }

      it "raises error with exit code" do
        error = begin
                  described_class.run('foo', 'bar')
                  nil
                rescue => ex
                  ex
                end

        expect(error).to be_a(described_class::Error::CommandFailed)
        expect(error.exit_code).to eq(123)
      end
    end
  end

  describe '.capture' do
    context "with a succeeding command" do
      let(:exit_code) { 0 }
      let(:io) { instance_double(IO) }
      let(:output) { 'some output' }

      before do
        allow(io).to receive(:read).and_return(output)
      end

      it "captures stdout" do
        expect(IO).to receive(:popen).with(['foo', 'bar']).and_return(io)
        expect(described_class.capture('foo', 'bar')).to eq('some output')
      end
    end

    context "with a failing command" do
      let(:exit_code) { 123 }

      it "raises error with exit code" do
        error = begin
                  described_class.run('foo', 'bar')
                  nil
                rescue => ex
                  ex
                end

        expect(error).to be_a(described_class::Error::CommandFailed)
        expect(error.exit_code).to eq(123)
      end
    end
  end
end
