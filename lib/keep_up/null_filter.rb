# frozen_string_literal: true

module KeepUp
  # Simple dependency filter that acccepts everything.
  class NullFilter
    def call(_dep)
      true
    end
  end
end
