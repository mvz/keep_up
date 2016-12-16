require 'bundler'
require_relative 'gemfile_filter'
require_relative 'gemspec_filter'
require_relative 'dependency'

module KeepUp
  # A Gemfile with its current set of locked dependencies.
  class Bundle
    def initialize(definition_builder:)
      @definition_builder = definition_builder
    end

    def direct_dependencies
      gemspec_dependencies + gemfile_dependencies
    end

    def apply_updated_dependency(dependency)
      puts "Updating #{dependency.name} to #{dependency.version}"
      update_gemfile_contents(dependency)
      update_gemspec_contents(dependency)
      update_lockfile(dependency)
    end

    private

    attr_reader :definition_builder

    def gemfile_dependencies
      build_dependencies bundler_lockfile.dependencies
    end

    def gemspec_dependencies
      gemspec_source = bundler_lockfile.sources.
        find { |it| it.is_a? Bundler::Source::Gemspec }
      return [] unless gemspec_source
      build_dependencies gemspec_source.gemspec.dependencies
    end

    def build_dependencies(deps)
      deps.map { |dep| build_dependency dep }.compact
    end

    def build_dependency(dep)
      spec = locked_spec dep
      return unless spec
      Dependency.new(dependency: dep, locked_spec: spec)
    end

    def locked_spec(dep)
      bundler_lockfile.specs.find { |it| it.name == dep.name }
    end

    def bundler_lockfile
      @bundler_lockfile ||= bundler_definition.locked_gems
    end

    def bundler_definition
      @bundler_definition ||= definition_builder.build(false)
    end

    def update_gemfile_contents(update)
      current_dependency = gemfile_dependencies.find { |it| it.name == update.name }
      return unless current_dependency
      return if current_dependency.matches_spec?(update)

      update = current_dependency.generalize_specification(update)

      contents = File.read 'Gemfile'
      updated_contents = GemfileFilter.apply(contents, update)
      File.write 'Gemfile', updated_contents
    end

    def update_gemspec_contents(update)
      current_dependency = gemspec_dependencies.find { |it| it.name == update.name }
      return unless current_dependency
      return if current_dependency.matches_spec?(update)

      update = current_dependency.generalize_specification(update)

      contents = File.read gemspec_name
      updated_contents = GemspecFilter.apply(contents, update)
      File.write gemspec_name, updated_contents
    end

    def gemspec_name
      @gemspec_name ||= begin
                          gemspecs = Dir.glob('*.gemspec')
                          case gemspecs.count
                          when 1
                            gemspecs.first
                          else
                            raise '???'
                          end
                        end
    end

    def update_lockfile(update)
      Bundler.clear_gemspec_cache
      definition_builder.build(gems: [update.name]).lock('Gemfile.lock')
      true
    rescue Bundler::VersionConflict
      puts 'Update failed'
      false
    end
  end
end
