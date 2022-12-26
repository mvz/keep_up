# frozen_string_literal: true

require "rubygems/package"

Before do
  # Set Aruba environment to match unbundled environment
  empty_env = with_environment { Bundler.with_unbundled_env { ENV.to_h } }
  aruba_env = aruba.environment.to_h
  (aruba_env.keys - empty_env.keys).each do |key|
    delete_environment_variable key
  end
  empty_env.each do |k, v|
    set_environment_variable k, v
  end

  # Set RUBYLIB so Ruby can find project's lib/ without Bundler
  project_lib = File.expand_path("../../lib", __dir__)
  set_environment_variable("RUBYLIB", project_lib)
end
