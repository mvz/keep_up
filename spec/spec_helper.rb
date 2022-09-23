# frozen_string_literal: true

require "simplecov"
$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "keep_up"

RSpec.configure do |config|
  config.example_status_persistence_file_path = "spec/examples.txt"
end
