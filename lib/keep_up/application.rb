require 'bundler'
require 'open3'

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
      report_up_to_date
    end

    def report_up_to_date
      puts 'Bundle up to date!'
      puts 'All done!'
    end
  end
end
