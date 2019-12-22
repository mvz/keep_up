# frozen_string_literal: true

def write_local_gemfile(string)
  contents = "path 'libs'\n\n#{string}"
  write_file "Gemfile", contents
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
  base_path = "libs/#{gemname}-#{version}"
  spec = Gem::Specification.new do |s|
    s.name = gemname
    s.version = version
    s.authors = ["John Doe"]
  end
  write_file "#{base_path}/#{gemname}.gemspec", spec.to_ruby
  write_file "#{base_path}/lib/#{gemname}.rb", "true"
end

Given "a gem named {string} at version {string} depending on {string} at version {string}" \
  do |gemname, version, depname, depversion|
  base_path = "libs/#{gemname}-#{version}"
  spec = Gem::Specification.new do |s|
    s.name = gemname
    s.version = version
    s.authors = ["John Doe"]
    s.add_dependency depname, depversion
  end
  write_file "#{base_path}/#{gemname}.gemspec", spec.to_ruby
  write_file "#{base_path}/lib/#{gemname}.rb", "true"
end

Given "the initial bundle install committed" do
  run_command_and_stop "bundle install"
  write_file ".gitignore", "libs/"
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
