# frozen_string_literal: true

require_relative "lib/keep_up/version"

Gem::Specification.new do |spec|
  spec.name = "keep_up"
  spec.version = KeepUp::VERSION
  spec.authors = ["Matijs van Zuijlen"]
  spec.email = ["matijs@matijs.net"]

  spec.summary = "Automatically update your dependencies"
  spec.description =
    "Automatically update the dependencies listed in your Gemfile," \
    " Gemfile.lock, and gemspec."
  spec.homepage = "https://github.com/mvz/keep_up"

  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.2.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["rubygems_mfa_required"] = "true"

  spec.files = File.read("Manifest.txt").split
  spec.bindir = "bin"
  spec.executables = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "bundler", "~> 2.0"

  spec.add_development_dependency "aruba", "~> 2.3"
  spec.add_development_dependency "cucumber", "~> 10.0"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rake-manifest", "~> 0.2.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "rubocop", "~> 1.80"
  spec.add_development_dependency "rubocop-packaging", "~> 0.6.0"
  spec.add_development_dependency "rubocop-performance", "~> 1.25"
  spec.add_development_dependency "rubocop-rspec", "~> 3.7"
  spec.add_development_dependency "simplecov", "~> 0.22.0"
end
