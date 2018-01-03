# frozen_string_literal: true

module KeepUp
  # Filter that skips dependencies if their name is on the list of things to be skipped.
  class SkipFilter
    def initialize(skip_list)
      @skip_list = skip_list
    end

    def call(dep)
      !@skip_list.include?(dep.name)
    end
  end
end
