# frozen_string_literal: true

require 'bundler'

module KeepUp
  # Creates Bunder::Definition objects.
  class BundlerDefinitionBuilder
    def build
      Bundler::Definition.build('Gemfile', 'Gemfile.lock', false)
    end
  end
end
