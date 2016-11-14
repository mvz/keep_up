require 'bundler'
require 'open3'

module KeepUp
  # Error thrown when we can't go any further.
  class BailOut < RuntimeError
  end

  # Main application
  class Application
    def initialize(local:, test_command:)
      @local = local
      @test_command = test_command
    end

    def bundle(command)
      full_command = "bundle #{command} #{'--local' if @local}"
      run_quietly full_command
    end

    def bundle_install
      bundle 'install' or raise BailOut, 'bundle install failed'
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
      bundle 'outdated'
    end

    def bundle_update
      bundle 'update' or raise BailOut, 'Bundle update failed'
    end

    def sanity_check
      bundle_install
      run_test_suite
    end

    def run
      sanity_check

      if bundle_up_to_date?
        puts 'Bundle up to date!'
        puts 'All done!'
        return
      end

      # Try bundle update
      current_lock_file = read_lockfile
      bundle_update
      new_lock_file = read_lockfile
      if new_lock_file == current_lock_file
        puts 'Update had no effect!'
      else
        run_test_suite
      end

      if bundle_up_to_date?
        puts 'Bundle up to date!'
        puts 'All done!'
      else
        puts 'More work to do!'
      end
    end

    def read_lockfile
      Bundler.default_lockfile.read
    end
  end
end
