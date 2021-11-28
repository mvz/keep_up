# frozen_string_literal: true

require "bundler/gem_tasks"
require "rake/manifest/task"
require "rspec/core/rake_task"
require "cucumber/rake/task"

RSpec::Core::RakeTask.new(:spec) do |t|
  t.ruby_opts = ["-rbundler/setup -rsimplecov -w"]
end

Cucumber::Rake::Task.new(:features)

Rake::Manifest::Task.new do |t|
  t.patterns = ["{lib,bin}/**/*", "COPYING.LESSER", "LICENSE.txt", "*.md"]
end

task build: ["manifest:check"]

task default: [:spec, :features, "manifest:check"]
