# frozen_string_literal: true

module KeepUp
  # Filter to update dependency information in a Gemfile.
  module GemfileFilter
    def self.apply(contents, dependency)
      matcher = dependency_matcher(dependency)
      contents.each_line.map do |line|
        if line =~ matcher
          match = Regexp.last_match
          "#{match[1]}#{dependency.version}#{match[2]}"
        else
          line
        end
      end.join
    end

    def self.dependency_matcher(dependency)
      /
        ^(\s*gem\s+['"]#{dependency.name}['"],
        \s+\[?['"](?:~>|=)?\ *)
        [^'"]*
        (['"]\]?[^\]]*)
        $
      /mx
    end
  end
end
