# frozen_string_literal: true

module KeepUp
  # Interface to the version control system (only Git is supported).
  class VersionControl
    def initialize(runner:)
      @runner = runner
    end

    def commit_changes(dependency)
      @runner.run "git commit -am 'Update #{dependency.name} to version #{dependency.version}'"
    end

    def revert_changes
      @runner.run "git reset --hard"
    end

    def clean?
      @runner.run("git status -s") == ""
    end
  end
end
