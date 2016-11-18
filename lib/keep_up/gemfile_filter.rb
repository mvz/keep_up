module KeepUp
  module GemfileFilter
    def self.apply(contents, dependency)
      dependency_name = dependency.name
      new_version = dependency.version

      updated_contents = contents.each_line.map do |line|
        if line =~ /^(\s*gem ['"]#{dependency_name}['"], ['"](~> *)?)[^'"]*(['"].*)/m
          match = Regexp.last_match
          "#{match[1]}#{new_version}#{match[3]}"
        else
          line
        end
      end
      updated_contents.join
    end
  end
end
