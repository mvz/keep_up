module KeepUp
  # Apply potential updates to a Gemfile.
  class Updater
    attr_reader :gemfile, :repository

    def initialize(gemfile:, repository:)
      @gemfile = gemfile
      @repository = repository
    end

    def run
      possible_updates.each do |update|
        gemfile.apply_updated_dependency update
      end
    end

    def possible_updates
      gemfile.direct_dependencies.
        map { |dep| repository.updated_dependency_for dep }.compact
    end
  end
end
