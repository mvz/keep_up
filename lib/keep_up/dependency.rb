module KeepUp
  # Single dependency with its current locked version.
  class Dependency
    def initialize(dependency:, locked_spec:)
      @dependency = dependency
      @locked_spec = locked_spec
    end

    def name
      @dependency.name
    end

    def version
      @dependency.requirements_list.first
    end

    def locked_version
      @locked_spec.version
    end

    def matches_spec?(spec)
      @dependency.matches_spec? spec
    end
  end
end
