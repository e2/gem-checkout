require 'gem-checkout/repository/git'


module Gem
  module Checkout
    module Repository
      class GitHub
        class Error < Repository::Error
          class BadURI < Error
            class NotGitHub < BadURI
            end

            class NoProjectName < BadURI
            end
          end
        end

        def initialize(vague_uri)
          uri = vague_uri.dup
          fail Error::BadURI::NotGitHub unless uri.host == 'github.com'


          uri.scheme = 'https'
          uri.port = nil
          uri.userinfo = nil
          uri.query = nil
          uri.fragment = nil
          uri = URI.parse(uri.to_s)


          m = /(?<org>[[:alnum:]]+)\/(?<project>[[:alnum:]]+)/.match(uri.path)
          fail Error::BadURI::NoProjectName unless m
          org = m[:org]
          project = m[:project]
          uri.path = "/#{org}/#{project}.git"

          @git = Git.new(uri)
        end

        def clone(*args)
          @git.clone(*args)
        end

        def checkout(*args)
          @git.checkout(*args)
        end

        def get_tag_ref(*args)
          @git.get_tag_ref(*args)
        end
      end
    end
  end
end

