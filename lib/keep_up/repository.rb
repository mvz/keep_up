module KeepUp
  # Picks updated versions for dependencies.
  class Repository
    attr_reader :index

    def initialize(index:)
      @index = index
    end

    def updated_dependency_for(dependency)
      candidates = index.search(dependency)
      latest = candidates.sort_by(&:version).last
      latest unless latest.version <= dependency.locked_version
    end
  end
end
