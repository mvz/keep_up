# frozen_string_literal: true

require 'bundler'
require_relative 'gemfile_filter'
require_relative 'gemspec_filter'
require_relative 'dependency'
require_relative 'runner'

module KeepUp
  # A Gemfile with its current set of locked dependencies.
  class Bundle
    OUTDATED_MATCHER = /([^ ]*) \(newest ([^,]*), installed ([^,]*)(?:, requested (.*))?\)/
    UPDATE_MATCHER = /(?:Using|Installing|Fetching) ([^ ]*) ([^ ]*)(?: \(was (.*))?\)/

    def initialize(definition_builder:, runner: Runner)
      @definition_builder = definition_builder
      @runner = runner
    end

    def dependencies
      result = @runner.run 'bundle outdated --parseable'
      lines = result.split("\n").reject(&:empty?)
      lines.map do |line|
        matchdata = OUTDATED_MATCHER.match line
        name = matchdata[1]
        version = matchdata[3]
        requirement_list = [matchdata[4]] if matchdata[4]
        Dependency.new(name: name, locked_version: version,
                       requirement_list: requirement_list)
      end
    end

    def check?
      bundler_definition.to_lock == File.read('Gemfile.lock')
    end

    def update_gemfile_contents(update)
      update = find_specification_update(gemfile_dependencies, update)
      return unless update
      update_specification_contents(update, 'Gemfile', GemfileFilter)
    end

    def update_gemspec_contents(update)
      update = find_specification_update(gemspec_dependencies, update)
      return unless update
      update_specification_contents(update, gemspec_name, GemspecFilter)
    end

    # Update lockfile and return resulting spec, or false in case of failure
    def update_lockfile(update)
      result = @runner.run "bundle update --conservative #{update.name}"
      lines = result.split("\n").reject(&:empty?)
      lines.each do |line|
        matchdata = UPDATE_MATCHER.match line
        next unless matchdata
        name = matchdata[1]
        next unless name == update.name
        version = matchdata[2]
        old_version = matchdata[3]
        next unless old_version
        current = Gem::Specification.new(name, old_version)
        result = Gem::Specification.new(name, version)
        return result if result.version > current.version
      end
      nil
    end

    private

    attr_reader :definition_builder

    def gemfile_dependencies
      raw = if Bundler::VERSION >= '1.15.'
              bundler_lockfile.dependencies.values
            else
              bundler_lockfile.dependencies
            end
      build_dependencies raw
    end

    def gemspec_dependencies
      gemspec_source = bundler_lockfile.sources.
        find { |it| it.is_a? Bundler::Source::Gemspec }
      return [] unless gemspec_source
      build_dependencies gemspec_source.gemspec.dependencies
    end

    def build_dependencies(deps)
      deps.map { |dep| build_dependency dep }.compact
    end

    def build_dependency(dep)
      spec = locked_spec dep
      return unless spec
      Dependency.new(name: dep.name, requirement_list: dep.requirement.as_list,
                     locked_version: spec.version)
    end

    def locked_spec(dep)
      bundler_lockfile.specs.find { |it| it.name == dep.name }
    end

    def bundler_lockfile
      @bundler_lockfile ||= bundler_definition.locked_gems
    end

    def bundler_definition
      @bundler_definition ||= definition_builder.build(false)
    end

    def find_specification_update(current_dependencies, update)
      current_dependency = current_dependencies.find { |it| it.name == update.name }
      return if !current_dependency || current_dependency.matches_spec?(update)
      current_dependency.generalize_specification(update)
    end

    def update_specification_contents(update, file, filter)
      File.write file, filter.apply(File.read(file), update)
    end

    def gemspec_name
      @gemspec_name ||= Dir.glob('*.gemspec').first
    end
  end
end
