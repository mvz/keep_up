# frozen_string_literal: true

require_relative 'null_filter'

module KeepUp
  # Apply potential updates to a Gemfile.
  class Updater
    attr_reader :bundle, :repository, :version_control, :filter

    def initialize(bundle:, repository:, version_control:,
                   filter: NullFilter.new, out: STDOUT)
      @bundle = bundle
      @repository = repository
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
      bundle.dependencies.
        select { |dep| filter.call dep }.
        map { |dep| repository.updated_dependency_for dep }.compact.uniq
    end

    private

    def apply_updated_dependency(dependency)
      report_intent dependency
      bundle.update_gemfile_contents(dependency)
      bundle.update_gemspec_contents(dependency)
      result = bundle.update_lockfile(dependency)
      report_result dependency, result
      result
    end

    def report_intent(dependency)
      @out.print "Updating #{dependency.name}"
    end

    def report_result(dependency, result)
      if result
        @out.puts " to #{result.version}"
      else
        @out.puts " to #{dependency.version}"
        @out.puts 'Update failed'
      end
    end
  end
end
