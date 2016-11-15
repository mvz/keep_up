require 'bundler'
require 'open3'
require_relative 'bundler_runner'

module KeepUp
  # Error thrown when we can't go any further.
  class BailOut < RuntimeError
  end

  # Main application
  class Application
    attr_reader :bundler_runner

    def initialize(local:, test_command:)
      @test_command = test_command
      @bundler_runner = BundlerRunner.new(local: local)
    end

    def run_quietly(full_command)
      puts "Running #{full_command}"
      _out, _err, status = Open3.capture3(full_command)
      status == 0
    end

    def run_test_suite
      run_quietly(@test_command) or raise BailOut, 'Running the test suite failed'
    end

    def bundle_up_to_date?
      bundler_runner.bundle_outdated
    end

    def sanity_check
      bundler_runner.bundle_install
      run_test_suite
    end

    def run
      sanity_check

      if bundle_up_to_date?
        report_up_to_date
        return
      end

      # Try bundle update
      current_lock_file = read_lockfile
      bundler_runner.bundle_update
      new_lock_file = read_lockfile
      if new_lock_file == current_lock_file
        puts 'Update had no effect!'
      else
        run_test_suite
      end

      if bundle_up_to_date?
        report_up_to_date
      else
        puts 'More work to do!'
      end
    end

    def report_up_to_date
      puts 'Bundle up to date!'
      puts 'All done!'
    end

    def read_lockfile
      bundler_runner.read_lockfile
    end
  end
end
