# frozen_string_literal: true

require 'open3'

module KeepUp
  # Encapsulate knowledge of running external commands
  module Runner
    module_function

    def run(command)
      stdout, status = Open3.capture2 command
      stdout
    end
  end
end
