# frozen_string_literal: true

SimpleCov.start do
  add_group "Main", "lib"
  add_group "Specs", "spec"
  enable_coverage :branch
end

SimpleCov.at_exit do
  SimpleCov.result.format!
end
