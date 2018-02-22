# frozen_string_literal: true

module KeepUp
  # Picks updated versions for dependencies.
  class Repository
    attr_reader :index

    def initialize(index:)
      @index = index
    end

    def updated_dependency_for(dependency)
      candidates = index.search(dependency).sort_by(&:version)
      regulars = candidates.reject { |it| it.version.prerelease? }

      latest = regulars.last

      if dependency.locked_version.prerelease?
        latest = candidates.last if latest.version <= dependency.locked_version
      end

      latest unless latest.version <= dependency.locked_version
    end
  end
end
