# frozen_string_literal: true

require_relative "runner"
require_relative "bundle"
require_relative "null_filter"
require_relative "skip_filter"
require_relative "updater"
require_relative "version_control"

module KeepUp
  # Error thrown when we can't go any further.
  class BailOut < RuntimeError
  end

  # Main application
  class Application
    def initialize(local:, skip:, test_command: nil, runner: Runner)
      @test_command = test_command
      @local = local
      @skip = skip
      @runner = runner
    end

    def run
      check_version_control_clean
      check_bundle_lockfile
      check_test_command_success
      update_all_dependencies
      report_done
    end

    private

    attr_reader :skip, :local, :runner

    def check_version_control_clean
      return if version_control.clean?

      raise BailOut, "Commit or stash your work before running 'keep_up'"
    end

    def check_bundle_lockfile
      return if bundle.check? && version_control.clean?

      version_control.revert_changes
      raise BailOut, "Make sure your Gemfile.lock is up-to-date before running 'keep_up'"
    end

    def check_test_command_success
      return unless @test_command

      puts "Test command set: #{@test_command}"

      return if updater.test_successfull?

      raise BailOut, "Test command failed. Fix your tests before running 'keep_up'"
    end

    def update_all_dependencies
      updater.run
    end

    def updater
      @updater ||= Updater.new(
        bundle: bundle,
        version_control: version_control,
        filter: filter,
        test_command: @test_command
      )
    end

    def version_control
      @version_control ||= VersionControl.new(runner: runner)
    end

    def bundle
      @bundle ||= Bundle.new(runner: runner, local: local)
    end

    def report_done
      puts "All done!"
    end

    def filter
      @filter ||=
        if skip.any?
          SkipFilter.new(skip)
        else
          NullFilter.new
        end
    end
  end
end
