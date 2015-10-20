require 'logger'

module Gem
  module Checkout
    class << self
      def logger=(logger)
        @logger = logger
      end

      def logger
        @logger ||= ::Logger.new(STDERR).tap { |logger| logger.level = Logger::WARN }
      end
    end
  end
end
