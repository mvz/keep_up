module KeepUp
  # Searches possibly remote gem index o find potential dependency updates.
  class LocalIndex
    def search(dependency)
      index.search(Bundler::Dependency.new(dependency.name, nil))
    end

    private

    def definition
      @definition ||=
        Bundler::Definition.build('Gemfile', 'Gemfile.lock', true).tap(&:resolve_with_cache!)
    end

    def index
      @index ||= definition.index
    end
  end
end

