module Gem
  module Checkout
    class Process
      class Error < RuntimeError
        class CommandFailed < Error
          attr_reader :exit_code

          def initialize(exit_code)
            @exit_code = exit_code
          end
        end
      end

      def self.run(*args)
        pid = Kernel.spawn(*args)
        result = ::Process.wait2(pid)
        exit_code = result.last.exitstatus
        fail(Error::CommandFailed, exit_code) unless exit_code.zero?
      end

      def self.capture(*args)
        IO.popen(args).read
      end
    end
  end
end
