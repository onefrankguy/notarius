require 'rake/clean'
require 'rspec/core/rake_task'

CLEAN.include 'coverage'

task :default => :spec

RSpec::Core::RakeTask.new :spec

desc 'Generate SimpleCov test coverage'
RSpec::Core::RakeTask.new :coverage do |t|
  t.rspec_opts = ['--require simplecov_helper']
end
