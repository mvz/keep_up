require 'bundler/gem_tasks'
require 'rspec/core/rake_task'
require 'cucumber/rake/task'
require 'rubocop/rake_task'

RSpec::Core::RakeTask.new(:spec)
Cucumber::Rake::Task.new(:features)
RuboCop::RakeTask.new

task default: [:spec, :features, :rubocop]
