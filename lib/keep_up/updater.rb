# frozen_string_literal: true

require_relative "null_filter"

module KeepUp
  # Apply potential updates to a Gemfile.
  class Updater
    attr_reader :bundle, :version_control, :filter

    def initialize(bundle:, version_control:, filter: NullFilter.new, out: $stdout)
      @bundle = bundle
      @version_control = version_control
      @filter = filter
      @out = out
    end

    def run
      possible_updates.each do |update|
        result = apply_updated_dependency update
        if result
          version_control.commit_changes result
        else
          version_control.revert_changes
        end
      end
    end

    def possible_updates
      bundle.dependencies
        .select { |dep| filter.call dep }
        .map { |dep| updated_dependency_for dep }.compact.uniq
    end

    private

    def apply_updated_dependency(dependency)
      report_intent dependency
      update = bundle.update_gemspec_contents(dependency)
      update2 = bundle.update_gemfile_contents(dependency)
      update ||= update2
      result = bundle.update_lockfile(dependency)
      report_result dependency, result
      update || result if result
    end

    def report_intent(dependency)
      @out.puts "Updating #{dependency.name}"
    end

    def report_result(dependency, result)
      if result
        @out.puts "Updated #{dependency.name} to #{result.version}"
      else
        @out.puts "Failed updating #{dependency.name} to #{dependency.version}"
      end
    end

    def updated_dependency_for(dependency)
      locked_version = dependency.locked_version
      newest_version = dependency.newest_version
      return unless newest_version > locked_version

      Gem::Specification.new(dependency.name, newest_version)
    end
  end
end
