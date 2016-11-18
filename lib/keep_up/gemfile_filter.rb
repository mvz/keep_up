module KeepUp
  module GemfileFilter
    def self.apply(contents, dependency)
      dependency_name = dependency.name
      new_version = dependency.version

      updated_contents = contents.each_line.map do |line|
        if line =~ /gem ['"]#{dependency_name}['"],/
          line.sub /gem.*/, "gem '#{dependency_name}', '#{new_version}'"
        else
          line
        end
      end
      updated_contents.join
    end
  end
end
