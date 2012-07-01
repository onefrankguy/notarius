require 'rake/clean'
require 'rspec/core/rake_task'

CLEAN.include 'doc'
CLEAN.include 'coverage'
CLEAN.include '*.gem'
CLEAN.include '.yardoc'

desc 'Run specs.'
task :default => :spec

desc 'Run specs.'
RSpec::Core::RakeTask.new :spec

desc 'Generate SimpleCov spec coverage.'
RSpec::Core::RakeTask.new :coverage do |t|
  t.rspec_opts = ['--require simplecov_helper']
end

desc 'Build the gem.'
task :build do
  sh "gem build #{name}.gemspec"
end

def name
  @name ||= Dir['*.gemspec'].first.split('.').first
end
