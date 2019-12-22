# frozen_string_literal: true

module KeepUp
  # Single dependency with its current locked version.
  class Dependency
    def initialize(name:, requirement_list:, locked_version:, newest_version:)
      @name = name
      @requirement_list = requirement_list
      @locked_version = Gem::Version.new locked_version
      @newest_version = Gem::Version.new newest_version
    end

    attr_reader :name, :locked_version, :newest_version

    def requirement
      @requirement ||= Gem::Requirement.new @requirement_list
    end

    def matches_spec?(spec)
      dependency.matches_spec? spec
    end

    def generalize_specification(specification)
      return specification if requirement.exact?

      segments = specification.version.segments
      return specification if segments.count <= segment_count

      version = segments.take(segment_count).join(".")
      Gem::Specification.new(specification.name, version)
    end

    def ==(other)
      other.name == name &&
        other.locked_version == locked_version &&
        other.newest_version == newest_version &&
        other.requirement == requirement
    end

    private

    def dependency
      @dependency ||= Gem::Dependency.new name, requirement
    end

    def segment_count
      @segment_count ||= begin
                           _, ver = requirement.requirements.first
                           ver.segments.count
                         end
    end
  end
end
