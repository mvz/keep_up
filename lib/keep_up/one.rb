# frozen_string_literal: true

module KeepUp
  # Fetch value from an array with exactly one element
  module One
    def self.fetch(arr)
      case arr.count
      when 1
        arr.first
      else
        raise 'Expected exactly one element'
      end
    end
  end
end
