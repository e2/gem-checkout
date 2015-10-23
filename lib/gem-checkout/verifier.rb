require 'digest/sha1'
require 'pathname'

require 'gem-checkout/logger'

module Gem
  module Checkout
    class Verifier
      class Gem
        class << self
          def fetch(name, version)
            version_opts = ['-v', version]
            fail "failed to fetch gem #{name}" unless system("gem", "fetch", "-V", *version_opts, name)
          end

          def build(gemspec)
            fail "failed to build using #{gemspec}"  unless system("gem", "build", gemspec)
          end
        end
      end

      class Tar
        class << self
          def extract_file(archive, file)
            fail "failed to untar #{file} from #{archive}" unless system("tar", "xf", archive, file)
          end

          def extract_compressed(archive)
            fail "failed to untar#{archive}" unless system("tar", "zxf", archive)
          end
        end
      end

      class Error < RuntimeError
        class DataMismatch < Error
        end
      end

      def initialize(name, version)
        @name = name
        @version = version
      end

      def verify!
        file = build_local_gem
        local = get_payload_sum(file)
        remote = get_remote_payload_sum

        unless local == remote
          local_files = local.map(&:last)
          remote_files = remote.map(&:last)
          if local_files != remote_files
            logger.debug "Files present only in published gem: #{remote_files - local_files }"
            logger.debug "Files present only in local gem: #{local_files - remote_files }"
          else
            diff = remote - local
            diff.each do |checksum, f|
              logger.debug "Checksum mismatch: #{checksum} #{f}"
            end
          end
          fail Error::DataMismatch, "checksum mismatch (run in debug mode to see details)"
        end

      end

      private

      def name
        @name
      end

      def version
        @version
      end

      def digest(f)
        Digest::SHA256.file(f).hexdigest
      end

      def logger
        Checkout.logger
      end

      def build_local_gem
        logger.debug "Building #{name}-#{version}.gem from sources..."
        gemspec = detect_gemspec
        Gem.build(gemspec)
        File.expand_path("#{name}-#{version}.gem")
      end

      def detect_gemspec
        gemspecs = Dir['*.gemspec']
        fail "Too many gemspecs: #{gemspecs.inspect}" unless gemspecs.size == 1
        gemspecs.first
      end

      def tempdir
        Dir.mktmpdir do |dir|
          Dir.chdir(dir) do
            yield
          end
        end
      end

      def get_payload_sum(file)
        full_path = File.expand_path(file)
        logger.debug "Getting SHA digests for #{full_path}"

        results = []
        tempdir do
          data_file = "data.tar.gz"
          Tar.extract_file(full_path, data_file)

          archive_path = File.expand_path(data_file)

          tempdir do
            Tar.extract_compressed(archive_path)
            add_directory_sums(results, '.')
          end
        end
        results
      end

      def get_remote_payload_sum
        logger.debug "Fetching remote gem for verification"
        tempdir do
          Gem.fetch(name, version)
          file = "#{name}-#{version}.gem"
          return get_payload_sum(file)
        end
      end

      def add_directory_sums(results, dir)
        # TODO: check for filesystem loops/symlinks?
        Pathname.new(dir).children.each do |f|
          if File.directory?(f)
            add_directory_sums(results, f)
          else
            logger.debug "SHA digest #{File.expand_path(f)}"
            results << [digest(f), f]
          end
        end
      end
    end
  end
end
