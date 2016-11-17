require_relative 'remote_index'

module KeepUp
  class Repository
    attr_reader :remote_index

    def initialize(remote_index: RemoteIndex.new)
      @remote_index = remote_index
    end

    def updated_dependency_for(dependency)
      candidates = remote_index.search(dependency)
      latest = candidates.sort_by(&:version).last
      latest unless latest.version == dependency.locked_version
    end
  end
end
