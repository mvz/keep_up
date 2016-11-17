module KeepUp
  class Gemfile
    def direct_dependencies
      bundler_lockfile.dependencies
    end

    def bundler_lockfile
      @bundler_lockfile ||= Bundler::LockfileParser.new(File.read 'Gemfile.lock')
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
  end
end
