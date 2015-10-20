# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |s|
  s.name = "gem-checkout"
  s.version = '0.0.1'
  s.authors = ["Cezary Baginski"]
  s.email = ["cezary@chronomantic.net"]

  s.summary = "Gem command download and checkout repository at same version as gem"
  s.description = "Uses gem's metadata or version to work out which commit to checkout"
  s.homepage = "https://github.com/e2/gem-checkout"
  s.license = "MIT"

  s.files = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  s.add_dependency "gems", "~> 0.8"
  s.add_development_dependency "bundler", "~> 1.10"
end
