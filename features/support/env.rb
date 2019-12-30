# frozen_string_literal: true

require "rubygems/package"

Before do
  delete_environment_variable "RUBYOPT"
  delete_environment_variable "BUNDLE_BIN_PATH"
  delete_environment_variable "BUNDLE_GEMFILE"
end
