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

    def dependencies
      gemspec_dependencies + gemfile_dependencies + transitive_dependencies
    end

    def apply_updated_dependency(dependency)
      report_intent dependency
      update_gemfile_contents(dependency)
      update_gemspec_contents(dependency)
      result = update_lockfile(dependency)
      report_result dependency, result
      result
    end

    def check?
      bundler_definition.to_lock == File.read('Gemfile.lock')
    end

    private

    attr_reader :definition_builder

    def report_intent(dependency)
      print "Updating #{dependency.name}"
    end

    def report_result(dependency, result)
      if result
        puts " to #{result.version}"
      else
        puts " to #{dependency.version}"
        puts 'Update failed'
      end
    end

    def gemfile_dependencies
      raw = if Bundler::VERSION >= '0.15.'
              bundler_lockfile.dependencies.values
            else
              bundler_lockfile.dependencies
            end
      build_dependencies raw
    end

    def gemspec_dependencies
      gemspec_source = bundler_lockfile.sources.
        find { |it| it.is_a? Bundler::Source::Gemspec }
      return [] unless gemspec_source
      build_dependencies gemspec_source.gemspec.dependencies
    end

    def transitive_dependencies
      build_dependencies bundler_lockfile.specs.flat_map(&:dependencies).uniq
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

    # Update lockfile and return resulting spec, or false in case of failure
    def update_lockfile(update)
      Bundler.clear_gemspec_cache
      definition = definition_builder.build(gems: [update.name])
      definition.lock('Gemfile.lock')
      current = locked_spec(update)
      result = definition.specs.find { |it| it.name == update.name }
      result if result.version > current.version
    rescue Bundler::VersionConflict
      false
    end
  end
end
