# frozen_string_literal: true

require "bundler/gem_tasks"
require "rspec/core/rake_task"
require "cucumber/rake/task"

RSpec::Core::RakeTask.new(:spec) do |t|
  t.ruby_opts = ["-rbundler/setup -rsimplecov -w"]
end

Cucumber::Rake::Task.new(:features)

task default: [:spec, :features]
