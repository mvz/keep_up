# frozen_string_literal: true

module KeepUp
  # Searches possibly remote gem index to find potential dependency updates.
  class GemIndex
    def initialize(definition_builder:)
      @definition_builder = definition_builder
    end

    def search(dependency)
      index.search(Bundler::Dependency.new(dependency.name, nil))
    end

    private

    attr_reader :definition_builder

    def definition
      @definition ||= definition_builder.build(true)
    end

    def index
      @index ||= definition.index
    end
  end
end
