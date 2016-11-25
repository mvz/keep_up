module KeepUp
  # Simple filter that acccepts everything.
  class NullFilter
    def call(_dep)
      true
    end
  end
end
