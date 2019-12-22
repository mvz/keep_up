# frozen_string_literal: true

lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "keep_up/version"

Gem::Specification.new do |spec|
  spec.name          = "keep_up"
  spec.version       = KeepUp::VERSION
  spec.authors       = ["Matijs van Zuijlen"]
  spec.email         = ["matijs@matijs.net"]

  spec.summary       = "Automatically update your dependencies"
  spec.description =
    "Automatically update the dependencies listed in your Gemfile," \
    " Gemfile.lock, and gemspec."
  spec.homepage      = "https://github.com/mvz/keep_up"
  spec.license       = "MIT"

  spec.files = `git ls-files -z`.split("\x0")
    .reject { |f| f.match(%r{^(test|script|spec|features)/}) }

  spec.bindir        = "bin"
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.required_ruby_version = ">= 2.4.0"

  spec.add_runtime_dependency "bundler", [">= 1.15", "< 3.0"]

  spec.add_development_dependency "aruba", "~> 0.14.2"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "simplecov", "~> 0.17.0"
end
