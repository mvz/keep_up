require 'bundler'
require 'open3'
require_relative 'updater'
require_relative 'gemfile'
require_relative 'repository'
require_relative 'version_control'

module KeepUp
  # Error thrown when we can't go any further.
  class BailOut < RuntimeError
  end

  # Main application
  class Application
    def initialize(local:, test_command:)
      @test_command = test_command
      @local = local
    end

    def run
      update_all_dependencies
      report_up_to_date
    end

    def update_all_dependencies
      Updater.new(gemfile: Gemfile.new,
                  repository: Repository.new,
                  version_control: VersionControl.new).run
    end

    def report_up_to_date
      puts 'Bundle up to date!'
      puts 'All done!'
    end
  end
end
