# frozen_string_literal: true

require_relative "gemfile_filter"
require_relative "gemspec_filter"
require_relative "dependency"
require_relative "dependency_set"

module KeepUp
  # A Gemfile with its current set of locked dependencies.
  class Bundle
    OUTDATED_MATCHER =
      /([^ ]*) \(newest ([^,]*), installed ([^,]*)(?:, requested (.*))?\)/.freeze
    UPDATE_MATCHER =
      /(?:Using|Installing|Fetching) ([^ ]*) ([^ ]*)(?: \(was (.*)\))?/.freeze

    def initialize(runner:, local:)
      @runner = runner
      @local = local
    end

    def dependencies
      @dependencies ||=
        begin
          command = "bundle outdated --parseable#{" --local" if @local}"
          lines = run_filtered command, OUTDATED_MATCHER
          lines.map do |name, newest, version, requirement|
            build_dependency(name, newest, version, requirement)
          end
        end
    end

    def dependency_set
      @dependency_set ||= DependencySet.new(dependencies)
    end

    def check?
      _, status = @runner.run2 "bundle check"
      status == 0
    end

    def update_gemfile_contents(update)
      update = dependency_set.find_specification_update(update)
      return unless update

      update if GemfileFilter.apply_to_file("Gemfile", update)
    end

    def update_gemspec_contents(update)
      return unless gemspec_name

      update = dependency_set.find_specification_update(update)
      return unless update

      update if GemspecFilter.apply_to_file(gemspec_name, update)
    end

    # Update lockfile and return resulting spec, or false in case of failure
    def update_lockfile(update, old_version)
      update_name = update.name
      command = "bundle update#{" --local" if @local} --conservative #{update_name}"
      lines = run_filtered command, UPDATE_MATCHER
      lines.each do |name, version, _old_version|
        next unless name == update_name && old_version

        current = Gem::Specification.new(name, old_version)
        result = Gem::Specification.new(name, version)
        return result if result.version > current.version
      end
      nil
    end

    private

    def gemspec
      @gemspec ||=
        if gemspec_name
          gemspec_path = File.expand_path(gemspec_name)
          eval File.read(gemspec_name), nil, gemspec_path
        end
    end

    def gemspec_dependencies
      @gemspec_dependencies ||=
        if gemspec
          gemspec.dependencies
        else
          []
        end
    end

    def build_dependency(name, newest, version, requirement)
      requirement_list = requirement&.split(/,\s*/)
      requirement_list ||= fetch_gemspec_dependency_requirements(name)
      version = version.split.first
      newest = newest.split.first
      Dependency.new(
        name: name,
        locked_version: version,
        newest_version: newest,
        requirement_list: requirement_list
      )
    end

    def fetch_gemspec_dependency_requirements(name)
      dep = gemspec_dependencies.find { |it| it.name == name }
      return unless dep

      dep.requirements_list
    end

    def gemspec_name
      @gemspec_name ||= Dir.glob("*.gemspec").first
    end

    def run_filtered(command, regexp)
      result = @runner.run command
      lines = result.split("\n").reject(&:empty?)
      lines.map do |line|
        match_data = regexp.match line
        next unless match_data

        match_data.to_a[1..]
      end.compact
    end
  end
end
