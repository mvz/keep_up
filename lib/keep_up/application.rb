require 'bundler'
require 'open3'

module KeepUp
  class BailOut < RuntimeError
  end

  class Application
    def initialize(local)
      @local = local
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
      success = run_quietly('bundle exec rake')
      unless success
        raise BailOut, 'Running the test suite failed'
      end
    end

    def bundle_up_to_date?
      success = bundle 'outdated'
      if success
        puts 'Bundle up to date!'
      else
        puts 'Bundle is outdated!'
      end
      success
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

      # Try bundle update
      current_lock_file = Bundler.default_lockfile.read
      if bundle_up_to_date?
        puts 'All done!'
        return
      end
      bundle_update

      new_lock_file = Bundler.default_lockfile.read
      if new_lock_file == current_lock_file
        puts 'Update had no effect!'
      else
        run_test_suite
        if bundle_up_to_date?
          puts 'All done!'
          return
        end
      end

      puts 'More work to do!'

      # create branch
      # git status
      # git commit
      #
    end
  end
end
