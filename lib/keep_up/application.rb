# frozen_string_literal: true

require 'bundler'
require 'open3'
require_relative 'bundle'
require_relative 'null_filter'
require_relative 'skip_filter'
require_relative 'updater'
require_relative 'version_control'

module KeepUp
  # Error thrown when we can't go any further.
  class BailOut < RuntimeError
  end

  # Main application
  class Application
    def initialize(local:, test_command:, skip:)
      @test_command = test_command
      @local = local
      @skip = skip
    end

    def run
      sanity_check
      update_all_dependencies
      report_done
    end

    private

    attr_reader :skip, :local

    def sanity_check
      version_control.clean? or
        raise BailOut, "Commit or stash your work before running 'keep_up'"
      bundle.check? or
        raise BailOut, "Make sure your Gemfile.lock is up-to-date before running 'keep_up'"
    end

    def update_all_dependencies
      Updater.new(bundle: bundle,
                  version_control: version_control,
                  filter: filter).run
    end

    def version_control
      @version_control ||= VersionControl.new
    end

    def bundle
      @bundle ||= Bundle.new
    end

    def report_done
      puts 'All done!'
    end

    def filter
      @filter ||= if skip.any?
                    SkipFilter.new(skip)
                  else
                    NullFilter.new
                  end
    end
  end
end
