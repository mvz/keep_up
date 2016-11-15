module KeepUp
  # Facade class for access to bundler.
  class BundlerRunner
    def initialize(local:)
      @local = local
    end

    def bundle(command)
      full_command = "bundle #{command} #{'--local' if @local}"
      run_quietly full_command
    end

    def bundle_install
      bundle 'install' or raise BailOut, 'bundle install failed'
    end

    def bundle_update
      bundle 'update' or raise BailOut, 'Bundle update failed'
    end

    def bundle_outdated
      bundle 'outdated'
    end

    def run_quietly(full_command)
      puts "Running #{full_command}"
      _out, _err, status = Open3.capture3(full_command)
      status == 0
    end

    def read_lockfile
      Bundler.default_lockfile.read
    end
  end
end
