# frozen_string_literal: true

require_relative "../../spec/support/setup_bundle"

Given "a Gemfile specifying:" do |string|
  write_local_gemfile(string)
end

Given "a Gemfile.lock specifying:" do |string|
  write_file "Gemfile.lock", string
end

Given(
  "a gemspec for {string} depending on {string} at version {string}"
) do |gemname, depname, depversion|
  write_gemspec gemname, "0.0.1", depname => depversion
end

Given "the following remote gems:" do |table|
  table.rows.each do |gemname, version, dep_name, dep_version|
    dependencies = if dep_name && !dep_name.empty?
                     { dep_name => dep_version }
                   else
                     {}
                   end
    write_gem(gemname, version, dependencies)
  end
  generate_local_gem_index
end

Given "the initial bundle install committed" do
  run_command_and_stop "bundle config set path 'vendor'"
  run_command_and_stop "bundle install --quiet"
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
  matcher = /
    s.add_runtime_dependency\(
    %q<#{Regexp.escape depname}>(.freeze)?,         # Matches the dependency name
    \ \["#{Regexp.escape depversion}"(.freeze)?\]   # Matches the dependency version
    \)/x
  expect("#{gemname}.gemspec").to have_file_content matcher
end
