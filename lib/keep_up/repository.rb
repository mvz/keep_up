# frozen_string_literal: true

module KeepUp
  # Picks updated versions for dependencies.
  class Repository
    attr_reader :index

    def initialize(index:)
      @index = index
    end

    def updated_dependency_for(dependency)
      target_version = dependency.locked_version

      candidates = index.
        search(dependency).
        reject { |it| it.version <= target_version }.
        sort_by(&:version)

      regulars = candidates.reject { |it| it.version.prerelease? }

      latest = regulars.last
      latest = candidates.last if !latest && target_version.prerelease?
      latest
    end
  end
end
