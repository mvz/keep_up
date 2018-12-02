# frozen_string_literal: true

module KeepUp
  # Picks updated versions for dependencies.
  class Repository
    def updated_dependency_for(dependency)
      locked_version = dependency.locked_version
      newest_version = dependency.newest_version
      return unless newest_version > locked_version
      Gem::Specification.new(dependency.name, newest_version)
    end
  end
end
