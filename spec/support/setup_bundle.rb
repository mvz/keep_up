# frozen_string_literal: true

require "rubygems/package"

def write_local_gemfile(string)
  gem_path = expand_path("libs")
  contents = "source 'file://#{gem_path}'\n\n#{string}"
  write_file "Gemfile", contents
end

def write_gem(gemname, version, dependencies = {})
  spec = Gem::Specification.new do |s|
    s.name = gemname
    s.version = version
    s.authors = ["John Doe"]
    s.files = ["lib/#{gemname}.rb"]
    dependencies.each do |depname, depversion|
      s.add_dependency depname, depversion
    end
  end
  create_gem_in_local_source(spec)
end

def create_gem_in_local_source(spec)
  gemname = spec.name
  versioned_name = "#{gemname}-#{spec.version}"
  base_path = "libs/#{versioned_name}"
  write_file "#{base_path}/lib/#{gemname}.rb", "true"
  Dir.chdir expand_path(base_path) do
    Gem::DefaultUserInteraction.use_ui Gem::SilentUI.new do
      Gem::Package.build spec, true
    end
  end
  create_directory "libs/gems"
  copy "#{base_path}/#{versioned_name}.gem", "libs/gems"
end

def generate_local_gem_index
  run_command_and_stop "gem generate_index --silent --directory=libs"
end

def write_gemspec(gemname, version, dependencies)
  spec = Gem::Specification.new do |s|
    s.name = gemname
    s.version = version
    s.authors = ["John Doe"]
    dependencies.each do |depname, depversion|
      s.add_dependency depname, depversion
    end
  end
  write_file "#{gemname}.gemspec", spec.to_ruby
end
