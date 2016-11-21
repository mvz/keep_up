module KeepUp
  # Apply potential updates to a Gemfile.
  class Updater
    attr_reader :bundle, :repository, :version_control

    def initialize(bundle:, repository:, version_control:)
      @bundle = bundle
      @repository = repository
      @version_control = version_control
    end

    def run
      possible_updates.each do |update|
        if bundle.apply_updated_dependency update
          version_control.commit_changes update
        else
          version_control.revert_changes
        end
      end
    end

    def possible_updates
      bundle.direct_dependencies.
        map { |dep| repository.updated_dependency_for dep }.compact
    end
  end
end
