# frozen_string_literal: true

module KeepUp
  # Simple dependency filter that accepts everything.
  class NullFilter
    def call(_dep)
      true
    end
  end
end
