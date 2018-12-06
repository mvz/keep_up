# frozen_string_literal: true

require 'open3'

module KeepUp
  # Encapsulate knowledge of running external commands
  module Runner
    module_function

    def run(command)
      stdout, = run2 command
      stdout
    end

    def run2(command)
      Open3.capture2 command
    end
  end
end
