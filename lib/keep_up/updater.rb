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
        .select { |dep| updateable_dependency? dep }.uniq
    end

    private

    def apply_updated_dependency(dependency)
      report_intent dependency

      specification = updated_specification_for(dependency)

      update =
        bundle.update_gemspec_contents(specification) ||
        bundle.update_gemfile_contents(specification)
      result = bundle.update_lockfile(specification, dependency.locked_version)
      report_result specification, result
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

    def updateable_dependency?(dependency)
      locked_version = dependency.locked_version
      newest_version = dependency.newest_version
      newest_version > locked_version
    end

    def updated_specification_for(dependency)
      Gem::Specification.new(dependency.name, dependency.newest_version)
    end
  end
end
