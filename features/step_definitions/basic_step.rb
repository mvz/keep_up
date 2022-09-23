# frozen_string_literal: true

def write_local_gemfile(string)
  gem_path = expand_path("libs")
  contents = "source 'file://#{gem_path}'\n\n#{string}"
  write_file "Gemfile", contents
end

def write_gem(gemname, version, dependencies)
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

Given "a Gemfile specifying:" do |string|
  write_local_gemfile(string)
end

Given(
  "a gemspec for {string} depending on {string} at version {string}"
) do |gemname, depname, depversion|
  write_gemspec gemname, "0.0.1", depname => depversion
end

Given "a gem named {string} at version {string}" do |gemname, version|
  write_gem(gemname, version, {})
end

Given(
  "a gem named {string} at version {string} depending on {string} at version {string}"
) do |gemname, version, depname, depversion|
  write_gem(gemname, version, depname => depversion)
end

Given "the initial bundle install committed" do
  if Bundler::VERSION < "2.0"
    run_command_and_stop "bundle install --quiet --path 'vendor'"
  else
    run_command_and_stop "bundle config set path 'vendor'"
    run_command_and_stop "bundle install --quiet"
  end
  write_file ".gitignore", "libs/\nvendor/"
  run_command_and_stop "git init -q"
  run_command_and_stop "git config user.name 'Foo Bar'"
  run_command_and_stop "git config user.email 'foo@bar.net'"
  run_command_and_stop "git add ."
  run_command_and_stop "git commit -q -a -m 'Initial'"
end

When "I add a file without checking it in" do
  write_file "some_file.rb", "# This is a new file"
end

When "I update the Gemfile to specify:" do |string|
  write_local_gemfile(string)
end

When "I commit the changes without updating the bundle" do
  run_command_and_stop "git commit -am 'YOLO!'"
end

Then(
  "the gemspec for {string} should depend on {string} at version {string}"
) do |gemname, depname, depversion|
  depversion = "= #{depversion}" unless /^[~<>=]/.match?(depversion)
  matcher = /s.add_runtime_dependency\(%q<#{depname}>(.freeze)?, \["#{depversion}"\]\)/
  expect("#{gemname}.gemspec").to have_file_content matcher
end
