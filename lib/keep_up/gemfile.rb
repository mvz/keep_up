require 'bundler'

module KeepUp
  class Dependency
    def initialize(name:, version:, locked_version:)
      @name = name
      @version = version
      @locked_version = locked_version
    end

    attr_reader :name, :version, :locked_version
  end

  class Gemfile
    def direct_dependencies
      bundler_lockfile.dependencies.map do |dep|
        spec = bundler_lockfile.specs.find { |it| it.name == dep.name }
        next unless spec
        Dependency.new(name: dep.name, version: dep.requirements_list.first, locked_version: spec.version)
      end.compact
    end

    def apply_updated_dependency(dependency)
      dependency_name = dependency.name
      new_version = dependency.version

      puts "Updating #{dependency_name} to #{new_version}"

      contents = File.read 'Gemfile'
      updated_contents = contents.each_line.map do |line|
        if line =~ /gem ['"]#{dependency_name}['"],/
          "gem '#{dependency_name}', '#{new_version}'"
        else
          line
        end
      end
      File.write 'Gemfile', updated_contents
    end

    private

    def bundler_lockfile
      @bundler_lockfile ||= Bundler::LockfileParser.new(File.read 'Gemfile.lock')
    end
  end
end
