require 'ostruct'
require 'uri'
require 'logger'

require 'gem-checkout/repository/git-hub'
require 'gem-checkout/spec'

module Gem
  module Checkout
    class DataFinder
      class Error < RuntimeError
        class NoMatch < Error
        end
      end

      class << self
        def detect(klass, object, priorities)
          found = nil
          priorities.values.each do |fields|
            found = traverse_find(klass, object, fields)
            break if found
          end
          found
        end

        private

        def traverse_find(klass, object, fields)
          loop do
            fields.each do |field|
              url = object.public_send(field)
              begin
                return klass.new(url)
              rescue Error::NoMatch
                next
              end
            end

            object = object.alternative
            return nil unless object
            next
          end
        end
      end
    end

    class RepositoryInfo < DataFinder
      PRIORITIES = {
        recommended: %i(source_code_uri),
        sufficient: %i(source_code_url repository_uri repository_url),
        user_pages: %i(project_uri project_url homepage),
        last_resort: %i(bug_tracker_uri bug_tracker_url)
      }

      def self.detect(object)
        DataFinder.detect(self, object, PRIORITIES)
      end

      attr_reader :repository

      def initialize(url)
        fail Error::NoMatch if !url || url.empty?
        Gem::Checkout.logger.debug "Found non-empty url: #{url}"
        uri = URI.parse(url)
        @repository = Repository::GitHub.new(uri)
        Gem::Checkout.logger.debug "Detected GitHub repository url: #{uri}"
      rescue Gem::Checkout::Repository::GitHub::Error::BadURI
        fail Error::NoMatch
      end
    end

    class RepositoryHash < DataFinder
      PRIORITIES = {
        recommended: %i(source_reference),
        sufficient: %i(commit revision),
      }

      def self.detect(object)
        DataFinder.detect(self, object, PRIORITIES)
      end

      attr_reader :reference

      def initialize(reference)
        fail Error::NoMatch unless (reference && !reference.empty?)
        @reference = reference
        Gem::Checkout.logger.debug "Found gem's commit info: #{reference}"
      end
    end

    class Source
      attr_reader :source_reference
      attr_reader :repository

      class Error < RuntimeError
        class NoValidRepositoryFound
        end
      end

      def initialize(name, version=nil)
        Gem::Checkout.logger.debug "Gathering info about #{name} (#{version || 'latest'})"
        object = Spec.info(name, version)

        @name = name

        repository = RepositoryInfo.detect(object)
        fail Error::NoValidRepositoryFound unless repository
        @repository = repository.repository

        reference = RepositoryHash.detect(object)

        @source_reference =
          if reference
            reference.reference
          else
            Gem::Checkout.logger.warn "No metadata key with commit! Matching tag to version, which is insecure if you don't trust the repository owners!"
            @repository.get_tag_ref("v#{object.version}")
          end
        # TODO: check integrity of gem vs source
      end
    end
  end
end
