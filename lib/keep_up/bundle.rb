# frozen_string_literal: true

require 'bundler'
require_relative 'gemfile_filter'
require_relative 'gemspec_filter'
require_relative 'dependency'
require_relative 'runner'

module KeepUp
  # A Gemfile with its current set of locked dependencies.
  class Bundle
    OUTDATED_MATCHER =
      /([^ ]*) \(newest ([^,]*), installed ([^,]*)(?:, requested (.*))?\)/.freeze
    UPDATE_MATCHER =
      /(?:Using|Installing|Fetching) ([^ ]*) ([^ ]*)(?: \(was (.*))?\)/.freeze

    def initialize(definition_builder:, runner: Runner)
      @definition_builder = definition_builder
      @runner = runner
    end

    def dependencies
      lines = run_filtered 'bundle outdated --parseable', OUTDATED_MATCHER
      lines.map do |name, newest, version, requirement|
        requirement_list = requirement.split(/,\s*/) if requirement
        version = version.split(' ').first
        newest = newest.split(' ').first
        Dependency.new(name: name,
                       locked_version: version,
                       newest_version: newest,
                       requirement_list: requirement_list)
      end
    end

    def check?
      result = @runner.run 'bundle check'
      result == "The Gemfile's dependencies are satisfied\n"
    end

    def update_gemfile_contents(update)
      update = find_specification_update(dependencies, update)
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
      update_name = update.name
      lines = run_filtered "bundle update --conservative #{update_name}", UPDATE_MATCHER
      lines.each do |name, version, old_version|
        next unless name == update_name && old_version

        current = Gem::Specification.new(name, old_version)
        result = Gem::Specification.new(name, version)
        return result if result.version > current.version
      end
      nil
    end

    private

    attr_reader :definition_builder

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
                     locked_version: spec.version, newest_version: nil)
    end

    def locked_spec(dep)
      bundler_lockfile.specs.find { |it| it.name == dep.name }
    end

    def bundler_lockfile
      @bundler_lockfile ||= bundler_definition.locked_gems
    end

    def bundler_definition
      @bundler_definition ||= definition_builder.build
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

    def run_filtered(command, regexp)
      result = @runner.run command
      lines = result.split("\n").reject(&:empty?)
      lines.map do |line|
        matchdata = regexp.match line
        next unless matchdata

        matchdata.to_a[1..-1]
      end.compact
    end
  end
end
