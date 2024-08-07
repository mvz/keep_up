# frozen_string_literal: true

require_relative "null_filter"

module KeepUp
  # Apply potential updates to a Gemfile.
  class Updater
    attr_reader :bundle, :version_control, :filter, :test_command

    def initialize(bundle:, version_control:, test_command: nil,
                   filter: NullFilter.new, out: $stdout)
      @bundle = bundle
      @version_control = version_control
      @filter = filter
      @test_command = test_command
      @out = out
    end

    def run
      possible_updates.each do |update|
        gem_update_result = apply_updated_dependency(update)
        if gem_update_result && test_successfull?
          version_control.commit_changes gem_update_result
        else
          version_control.revert_changes
        end
      end
    end

    def test_successfull?
      return true unless @test_command

      test_status = Runner.run_and_return_status @test_command

      puts "Running Test - Result: #{test_status.exitstatus}"
      test_status.success?
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

      update = bundle.update_gemspec_contents(specification)
      update2 = bundle.update_gemfile_contents(specification)
      update ||= update2
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
