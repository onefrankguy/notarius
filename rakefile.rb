require 'rake/clean'
require 'rspec/core/rake_task'

CLEAN.include 'coverage'

desc 'Run specs.'
task :default => :spec

desc 'Run specs.'
RSpec::Core::RakeTask.new :spec

desc 'Generate SimpleCov spec coverage.'
RSpec::Core::RakeTask.new :coverage do |t|
  t.rspec_opts = ['--require simplecov_helper']
end
