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

    def locked_version
      @locked_spec.version
    end

    def matches_spec?(spec)
      @dependency.matches_spec? spec
    end

    def generalize_specification(specification)
      return specification if requirement.exact?
      segments = specification.version.segments
      return specification if segments.count <= segment_count
      version = segments.take(segment_count).join('.')
      Gem::Specification.new(specification.name, version)
    end

    private

    def requirement
      @dependency.requirement
    end

    def segment_count
      @segment_count ||= begin
                           _, ver = requirement.requirements.first
                           ver.segments.count
                         end
    end
  end
end
