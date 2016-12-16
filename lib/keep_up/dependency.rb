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

    def generalize_specification(specification)
      return specification if requirement.exact?

      _, ver = requirement.requirements.first
      segment_count = ver.segments.count
      new_segment_count = specification.version.segments.count

      return specification if new_segment_count <= segment_count

      version = specification.version.segments.take(segment_count).join('.')
      Gem::Specification.new(specification.name, version)
    end

    private

    def requirement
      @dependency.requirement
    end
  end
end
