require 'ostruct'
require 'gems'

require 'gem-checkout/logger'

module Gem
  module Checkout
    class Spec
      class Error < RuntimeError
        class NoSuchGem < Error
        end
      end

      module CommonMetadata
        attr_reader :alternative
        def initialize(data, alternative=nil)
          @alternative = alternative
          @data = OpenStruct.new(data)
        end

        def homepage
          read(:homepage_uri)
        end

        private

        def data
          @data
        end
      end

      class Local < Spec
        class Metadata
          include CommonMetadata

          %i(
            source_code_uri
            source_code_url
            repository_uri
            repository_url
            project_uri
            project_url
            source_reference
            commit
            revision
            bug_tracker_uri
            bug_tracker_url
          ).each do |name|
            define_method(name) do
              read(name)
            end
          end


          private

          def read(key)
            Gem::Checkout.logger.debug "Checking local metadata (#{key})"
            data.public_send(key) if data.respond_to?(key)
          end
        end

        def initialize(name, version, remote)
          @data = find_by_name(name, version)
          @name = name
          @version = version
          @remote = remote
        end

        # TODO: fake fields - just as proof of concept

        %i(
          source_code_uri
          source_code_url
          repository_uri
          repository_url
          project_uri
          project_url
          source_reference
          commit
          revision
        ).each do |name|
          define_method(name) do
            read(name)
          end
        end

        def homepage
          read(:homepage)
        end

        def version
          read(:version)
        end

        def alternative
          Metadata.new(data.metadata, @remote)
        end

        private

        def data
          @data
        end

        def find_by_name(*args)
          spec = Gem::Specification
          return spec.find_by_name(*args) if spec.respond_to?(:find_by_name)
          Gem.source_index.find_name(*args).last or raise Gem::LoadError
        end

        def read(key)
          Gem::Checkout.logger.debug "Checking local info (#{key})"
          data.public_send(key) if data.respond_to?(key)
        end
      end

      class Remote < Spec
        class Metadata
          include CommonMetadata

          %i(
            source_code_uri
            source_code_url
            repository_uri
            repository_url
            project_uri
            project_url
            source_reference
            commit
            revision
            bug_tracker_uri
            bug_tracker_url
          ).each do |name|
            define_method(name) do
              data.public_send(name) if data.respond_to?(name)
            end
          end

          private

          def read(key)
            Gem::Checkout.logger.debug "Checking remote metadata (#{key})"
            data.public_send(key) if data.respond_to?(key)
          end
        end

        def initialize(name, version)
          @data = nil
          @name = name
          @version = version

          #  @homepage = nil_when_empty(object.homepage)
          #  @homepage = nil_when_empty(object.homepage_uri)
        end

        %i(
          source_code_uri
          source_code_url
          repository_uri
          repository_url
          project_uri
          project_url
          source_reference
          commit
          revision
          bug_tracker_uri
          bug_tracker_url
        ).each do |name|
          define_method(name) do
            read(name)
          end
        end

        def alternative
          Metadata.new(data.metadata, nil)
        end

        def version
          data.number
        end

        def homepage
          base.homepage_uri
        end

        private

        def base
          @base ||=
            begin
              name = @name
              Gem::Checkout.logger.debug "Looking up latest gem info ..."
              result = Gems.info(name)
              return OpenStruct.new(result) if result.is_a?(Hash)
              fail Error::NoSuchGem, result
            end
        end

        def data
          @data ||= find_on_rubygems
        end

        def find_on_rubygems
          name = @name
          version = @version
          return base if version.nil?

          Gem::Checkout.logger.debug "Looking all gem versions ..."
          versions = Gems.versions(name)
          version = versions.detect do |info|
            info['number'] == version
          end

          fail Error::NoSuchGem, "Could not find #{name} at #{version} on rubygems.org (yanked gem?)" unless version
          Gem::Checkout.logger.debug "Found info matching gem version #{@version}"
          OpenStruct.new(version)
        end

        private

        def read(key)
          Gem::Checkout.logger.debug "Checking remote info (#{key})"
          data.public_send(key) if data.respond_to?(key)
        end
      end

      def self.info(name, version=nil)
        remote = Spec::Remote.new(name, version)
        Gem::Checkout.logger.debug "Checking for info locally ..."
        Spec::Local.new(name, version, remote)
      rescue Gem::LoadError
        Gem::Checkout.logger.debug "Checking for info remotely ..."
        remote
      end
    end
  end
end
