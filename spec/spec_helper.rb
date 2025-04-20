# frozen_string_literal: true

require "simplecov"
require "keep_up"

require "aruba/rspec"
require_relative "support/setup_bundle"

RSpec.configure do |config|
  config.example_status_persistence_file_path = "spec/examples.txt"
end
