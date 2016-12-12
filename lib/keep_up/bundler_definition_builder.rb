require 'bundler'

module KeepUp
  # Creates Bunder::Definition objects.
  class BundlerDefinitionBuilder
    def initialize(local: false)
      @local = local
    end

    def build(lock)
      definition = Bundler::Definition.build('Gemfile', 'Gemfile.lock', lock)
      if lock
        if local
          definition.resolve_with_cache!
        else
          definition.resolve_remotely!
        end
      end
      definition
    end

    private

    attr_reader :local
  end
end
