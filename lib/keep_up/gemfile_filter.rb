# frozen_string_literal: true

module KeepUp
  # Filter to update dependency information in a Gemfile.
  module GemfileFilter
    def self.apply(contents, dependency)
      contents.each_line.map do |line|
        if line =~ /^(\s*gem\s+['"]#{dependency.name}['"],\s+['"](~> *)?)[^'"]*(['"].*)/m
          match = Regexp.last_match
          "#{match[1]}#{dependency.version}#{match[3]}"
        else
          line
        end
      end.join
    end
  end
end
