require 'bundler'
require 'open3'
require_relative 'bundle'
require_relative 'bundler_definition_builder'
require_relative 'local_index'
require_relative 'null_filter'
require_relative 'remote_index'
require_relative 'repository'
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
      update_all_dependencies
      report_up_to_date
    end

    private

    attr_reader :skip, :local

    def update_all_dependencies
      Updater.new(bundle: bundle,
                  repository: Repository.new(index: index),
                  version_control: VersionControl.new,
                  filter: filter).run
    end

    def bundle
      Bundle.new(definition_builder: definition_builder)
    end

    def report_up_to_date
      puts 'Bundle up to date!'
      puts 'All done!'
    end

    def definition_builder
      @definition_builder ||= BundlerDefinitionBuilder.new(local: local)
    end

    def filter
      @filter ||= if skip.any?
                    SkipFilter.new(skip)
                  else
                    NullFilter.new
                  end

    end

    def index
      local ? LocalIndex.new : RemoteIndex.new
    end
  end
end
