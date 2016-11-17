module KeepUp
  class Updater
    attr_reader :gemfile, :repository

    def initialize(gemfile:, repository:)
      @gemfile = gemfile
      @repository = repository
    end

    def run
      gemfile.direct_dependencies.each do |dep|
        gemfile.apply_updated_dependency repository.updated_dependency_for dep
      end
    end
  end
end
