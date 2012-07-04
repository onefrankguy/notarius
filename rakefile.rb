require 'rake/clean'
require 'rspec/core/rake_task'

CLEAN.include 'doc'
CLEAN.include 'coverage'
CLEAN.include '*.gem'
CLEAN.include '.yardoc'

desc 'Run specs.'
task :default => :spec

desc 'Run specs.'
RSpec::Core::RakeTask.new :spec do |t|
  t.ruby_opts = ['-w']
end

desc 'Generate SimpleCov spec coverage.'
RSpec::Core::RakeTask.new :coverage do |t|
  t.rspec_opts = ['--require simplecov_helper']
end

desc 'Build the gem.'
task :build do
  sh "gem build #{name}.gemspec"
end

desc 'Install the gem'
task :install do
  sh "gem install ./#{name}-#{version}.gem"
end

desc 'Uninstall the gem'
task :uninstall do
  sh "gem uninstall #{name}"
end

begin
  gem 'flog'
  desc 'Flog the code'
  task :flog, [:flags] do |t, args|
    flags = args[:flags] ? "-#{args[:flags]}" : ''
    files = FileList['lib/**/*.rb'].join(' ')
    sh "flog #{flags} #{files}"
  end
rescue Gem::LoadError
end

def name
  @name ||= Dir['*.gemspec'].first.split('.').first
end

def version
  text = File.read("lib/#{name}/version.rb")
  text = text[/^\s*VERSION\s*=\s*.*/]
  @version ||= text.match(/.*VERSION\s*=\s*['"](.*)['"]/)[1]
end
