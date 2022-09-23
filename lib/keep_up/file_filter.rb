# frozen_string_literal: true

module KeepUp
  # Base class for file filters
  class FileFilter
    def self.apply_to_file(file, dependency)
      contents = File.read(file)
      updated_contents = apply(contents, dependency)
      if contents == updated_contents
        false
      else
        File.write file, updated_contents
        true
      end
    end
  end
end
