module KeepUp
  # Filter to update dependency information in a Gemspec.
  module GemspecFilter
    def self.apply(contents, dependency)
      contents.each_line.map do |line|
        if line =~ /^(.*_dependency[ (](?:['"]|%q.)#{dependency.name}., \[?['"](?:~>|=)? *)[^'"]*(['"].*)/m
          match = Regexp.last_match
          "#{match[1]}#{dependency.version}#{match[2]}"
        else
          line
        end
      end.join
    end
  end
end
