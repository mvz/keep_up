require 'bundler'
require 'open3'
require_relative 'bundle'
require_relative 'repository'
require_relative 'updater'
require_relative 'version_control'
require_relative 'null_filter'
require_relative 'remote_index'
require_relative 'skip_filter'

module KeepUp
  # Error thrown when we can't go any further.
  class BailOut < RuntimeError
  end

  # Main application
  class Application
    attr_reader :skip

    def initialize(local:, test_command:, skip:)
      @test_command = test_command
      @local = local
      @skip = skip
    end

    def run
      update_all_dependencies
      report_up_to_date
    end

    private

    def update_all_dependencies
      Updater.new(bundle: Bundle.new,
                  repository: Repository.new(index: RemoteIndex.new),
                  version_control: VersionControl.new,
                  filter: filter).run
    end

    def report_up_to_date
      puts 'Bundle up to date!'
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
