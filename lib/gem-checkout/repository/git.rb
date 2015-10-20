require 'gem-checkout/process'
require 'gem-checkout/repository'

module Gem
  module Checkout
    module Repository
      class Git
        class Error < Repository::Error
          class SingleTagNotFound < Error
          end

          class CloneFailed < Error
          end

          class CheckoutFailed < Error
          end

          class FailedToFetchTags < Error
          end
        end

        attr_reader :uri
        def initialize(uri)
          @uri = uri
        end

        def clone(options)
          dir = options[:directory]
          Process.run('git', 'clone', uri.to_s, dir)
        rescue Process::Error => ex
          fail Error::CloneFailed, "Failed to clone #{uri.to_s} (#{ex.message})"
        end

        def checkout(ref)
          Process.run('git', 'checkout', ref)
        rescue Process::Error => ex
          fail Error::CheckoutFailed, "Failed to checkout #{ref} (#{ex})"
        end

        def get_tag_ref(tag)
          output = Process.capture('git', 'ls-remote', '--tags', uri.to_s)
          tag_info = output.split("\n")
          matching = tag_info.select { |details| details =~ /refs\/tags\/#{tag}$/}
          unless matching.size == 1
            fail Error::SingleTagNotFound, "Expected to match 1 tag #{tag}, matched: #{matching.inspect}"
          end
          matching.first.split("\t").first
        rescue Process::Error => ex
          fail Error::FailedToFetchTags, ex.message
        end
      end
    end
  end
end
