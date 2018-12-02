SimpleCov.start do
  track_files 'lib/**/*.rb'
  add_filter 'spec/'
  coverage_dir 'tmp/coverage'
end

SimpleCov.at_exit do
  SimpleCov.result.format!
end
