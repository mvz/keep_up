module KeepUp
  # Apply potential updates to a Gemfile.
  class Updater
    attr_reader :gemfile, :repository, :version_control

    def initialize(gemfile:, repository:, version_control:)
      @gemfile = gemfile
      @repository = repository
      @version_control = version_control
    end

    def run
      possible_updates.each do |update|
        gemfile.apply_updated_dependency update
        version_control.commit_changes update
      end
    end

    def possible_updates
      gemfile.direct_dependencies.
        map { |dep| repository.updated_dependency_for dep }.compact
    end
  end
end
