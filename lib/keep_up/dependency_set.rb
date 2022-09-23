# frozen_string_literal: true

module KeepUp
  # Set of dependencies with their current locked versions.
  class DependencySet
    attr_reader :dependencies

    def initialize(dependencies)
      @dependencies = dependencies
    end

    def find_specification_update(update)
      current_dependency = dependencies.find { |it| it.name == update.name }
      return if !current_dependency || current_dependency.matches_spec?(update)

      current_dependency.generalize_specification(update)
    end
  end
end
