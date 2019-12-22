# frozen_string_literal: true

require_relative "gemfile_filter"
require_relative "gemspec_filter"
require_relative "dependency"

module KeepUp
  # A Gemfile with its current set of locked dependencies.
  class Bundle
    OUTDATED_MATCHER =
      /([^ ]*) \(newest ([^,]*), installed ([^,]*)(?:, requested (.*))?\)/.freeze
    UPDATE_MATCHER =
      /(?:Using|Installing|Fetching) ([^ ]*) ([^ ]*)(?: \(was (.*))?\)/.freeze

    def initialize(runner:, local:)
      @runner = runner
      @local = local
    end

    def dependencies
      @dependencies ||=
        begin
          command = "bundle outdated --parseable#{' --local' if @local}"
          lines = run_filtered command, OUTDATED_MATCHER
          lines.map do |name, newest, version, requirement|
            requirement_list = requirement&.split(/,\s*/)
            requirement_list ||= fetch_gemspec_dependency_requirements(name)
            version = version.split(" ").first
            newest = newest.split(" ").first
            Dependency.new(name: name,
                           locked_version: version,
                           newest_version: newest,
                           requirement_list: requirement_list)
          end
        end
    end

    def check?
      _, status = @runner.run2 "bundle check"
      status == 0
    end

    def update_gemfile_contents(update)
      update = find_specification_update(dependencies, update)
      return unless update

      update_specification_contents(update, "Gemfile", GemfileFilter)
    end

    def update_gemspec_contents(update)
      return unless gemspec_name

      update = find_specification_update(dependencies, update)
      return unless update

      update_specification_contents(update, gemspec_name, GemspecFilter)
    end

    # Update lockfile and return resulting spec, or false in case of failure
    def update_lockfile(update)
      update_name = update.name
      command = "bundle update#{' --local' if @local} --conservative #{update_name}"
      lines = run_filtered command, UPDATE_MATCHER
      lines.each do |name, version, old_version|
        next unless name == update_name && old_version

        current = Gem::Specification.new(name, old_version)
        result = Gem::Specification.new(name, version)
        return result if result.version > current.version
      end
      nil
    end

    private

    def gemspec
      @gemspec ||= if gemspec_name
                     gemspec_path = File.expand_path(gemspec_name)
                     eval File.read(gemspec_name), nil, gemspec_path
                   end
    end

    def gemspec_dependencies
      @gemspec_dependencies ||= if gemspec
                                  gemspec.dependencies
                                else
                                  []
                                end
    end

    def fetch_gemspec_dependency_requirements(name)
      dep = gemspec_dependencies.find { |it| it.name == name }
      return unless dep

      dep.requirements_list
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
      @gemspec_name ||= Dir.glob("*.gemspec").first
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
