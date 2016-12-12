# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'keep_up/version'

Gem::Specification.new do |spec|
  spec.name          = 'keep_up'
  spec.version       = KeepUp::VERSION
  spec.authors       = ['Matijs van Zuijlen']
  spec.email         = ['matijs@matijs.net']

  spec.summary       = 'Automatically update your dependencies'
  spec.description =
    'Automatically update the dependencies listed in your Gemfile,' \
    ' Gemfile.lock, and gemspec.'
  spec.homepage      = 'https://github.com/mvz/keep_up'
  spec.license       = 'MIT'

  spec.files = `git ls-files -z`.split("\x0").
    reject { |f| f.match(%r{^(test|script|spec|features)/}) }

  spec.bindir        = 'bin'
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'bundler', '~> 1.13'

  spec.add_development_dependency 'rake', '~> 12.0.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'aruba', '~> 0.14.2'
  spec.add_development_dependency 'rubocop', '~> 0.46.0'
  spec.add_development_dependency 'pry'
end
