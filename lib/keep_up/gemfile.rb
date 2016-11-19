require 'bundler'
require_relative 'gemfile_filter'

module KeepUp
  # Single dependency with its current locked version.
  class Dependency
    def initialize(name:, version:, locked_version:)
      @name = name
      @version = version
      @locked_version = locked_version
    end

    def matches?(spec)
      Gem::Dependency.new(name, version).matches_spec? spec
    end

    attr_reader :name, :version, :locked_version
  end

  # A Gemfile with its current set of locked dependencies.
  class Gemfile
    def direct_dependencies
      bundler_lockfile.dependencies.map do |dep|
        spec = locked_spec dep
        next unless spec
        Dependency.new(name: dep.name,
                       version: dep.requirements_list.first,
                       locked_version: spec.version)
      end.compact
    end

    def apply_updated_dependency(dependency)
      puts "Updating #{dependency.name} to #{dependency.version}"
      current_dependency = direct_dependencies.find { |it| it.name == dependency.name }
      if current_dependency && current_dependency.matches?(dependency)
        return
      end
      contents = File.read 'Gemfile'
      updated_contents = GemfileFilter.apply(contents, dependency)
      File.write 'Gemfile', updated_contents
    end

    private

    def locked_spec(dep)
      bundler_lockfile.specs.find { |it| it.name == dep.name }
    end

    def bundler_lockfile
      @bundler_lockfile ||= Bundler::LockfileParser.new(File.read('Gemfile.lock'))
    end
  end
end
