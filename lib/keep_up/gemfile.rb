module KeepUp
  class Gemfile
    def direct_dependencies
      bundler_lockfile.dependencies
    end

    def bundler_lockfile
      @bundler_lockfile ||= Bundler::LockfileParser.new(File.read 'Gemfile.lock')
    end

    def apply_updated_dependency(dependency)

    end
  end
end
