# frozen_string_literal: true

module KeepUp
  # Encapsulate knowledge of running external commands
  module Runner
    module_function

    def run(command)
      `#{command}`
    end
  end
end
