SimpleCov.start do
  track_files 'lib/**/*.rb'
  add_filter 'spec/'
  enable_coverage :branch
end

SimpleCov.at_exit do
  SimpleCov.result.format!
end
