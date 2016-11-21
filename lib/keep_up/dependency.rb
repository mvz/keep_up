module KeepUp
  # Single dependency with its current locked version.
  class Dependency
    def initialize(name:, version:, locked_version:)
      @name = name
      @version = version
      @locked_version = locked_version
    end

    def matches?(spec)
      Gem::Dependency.new(name, version).matches_spec? spec
    end

    attr_reader :name, :version, :locked_version
  end
end
