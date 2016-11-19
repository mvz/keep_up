module KeepUp
  # Interface to the version control system (only Git is supported).
  class VersionControl
    def commit_changes(dependency)
      `git ci -am "Update #{dependency.name} to #{dependency.version}"`
    end
  end
end
