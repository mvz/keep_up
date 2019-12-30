# frozen_string_literal: true

def write_local_gemfile(string)
  gem_path = expand_path("libs")
  contents = "source 'file://#{gem_path}'\n\n#{string}"
  write_file "Gemfile", contents
end

def create_gem_in_local_source(spec)
  gemname = spec.name
  version = spec.version
  versioned_name = "#{gemname}-#{version}"
  base_path = "libs/#{versioned_name}"
  write_file "#{base_path}/lib/#{gemname}.rb", "true"
  Dir.chdir expand_path(base_path) do
    Gem::Package.build spec, true
  end
  create_directory "libs/gems"
  copy "#{base_path}/#{versioned_name}.gem", "libs/gems"
  run_command_and_stop "gem generate_index --directory=libs"
end

Given "a Gemfile specifying:" do |string|
  write_local_gemfile(string)
end

Given "a gemspec for {string} depending on {string} at version {string}" \
  do |gemname, depname, depversion|
  spec = Gem::Specification.new do |s|
    s.name = gemname
    s.version = "0.0.1"
    s.authors = ["John Doe"]
    s.add_dependency depname, depversion
  end
  write_file "#{gemname}.gemspec", spec.to_ruby
end

Given "a gem named {string} at version {string}" do |gemname, version|
  spec = Gem::Specification.new do |s|
    s.name = gemname
    s.version = version
    s.authors = ["John Doe"]
    s.files = ["lib/#{gemname}.rb"]
  end
  create_gem_in_local_source(spec)
end

Given "a gem named {string} at version {string} depending on {string} at version {string}" \
  do |gemname, version, depname, depversion|
  spec = Gem::Specification.new do |s|
    s.name = gemname
    s.version = version
    s.authors = ["John Doe"]
    s.add_dependency depname, depversion
    s.files = ["lib/#{gemname}.rb"]
  end
  create_gem_in_local_source(spec)
end

Given "the initial bundle install committed" do
  run_command_and_stop "bundle install --path=vendor"
  write_file ".gitignore", "libs/\nvendor/"
  run_command_and_stop "git init"
  run_command_and_stop "git add ."
  run_command_and_stop "git commit -am 'Initial'"
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

Then "the gemspec for {string} should depend on {string} at version {string}" \
  do |gemname, depname, depversion|
  depversion = "= #{depversion}" unless /^[~<>=]/.match?(depversion)
  matcher = /s.add_runtime_dependency\(%q<#{depname}>(.freeze)?, \["#{depversion}"\]\)/
  expect("#{gemname}.gemspec").to have_file_content matcher
end
