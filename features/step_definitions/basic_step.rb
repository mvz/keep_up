Given(/^a Gemfile specifying:$/) do |string|
  contents = "path 'libs'\n\n#{string}"
  write_file 'Gemfile', contents
end

Given(/^a gem named "([^']+)" at version ([0-9.]+)$/) do |gemname, version|
  base_path = "libs/#{gemname}-#{version}"
  spec = Gem::Specification.new do |s|
    s.name = gemname
    s.version = version
    s.authors = ['John Doe']
  end
  write_file "#{base_path}/#{gemname}.gemspec", spec.to_ruby
  write_file "#{base_path}/lib/#{gemname}.rb", 'true'
end
