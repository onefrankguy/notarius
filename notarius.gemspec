$LOAD_PATH << File.join(File.dirname(__FILE__), 'lib')

require 'notarius/version'

Gem::Specification.new do |s|
  s.name = 'notarius'
  s.version = Notarius::VERSION
  s.required_ruby_version = '~> 1.9'

  s.summary = 'Notarius is a logging library with opinions.'
  s.description = <<EOF
Notarius is a logging library with opinions. The word "notarius" is
Latin for "shorthand writer". To this end, Notarius does everything
possible to encourage you to write short useful log messages.
EOF

  s.author = 'Frank Mitchell'
  s.email = 'me@frankmitchell.org'
  s.homepage = 'https://github.com/elimossinary/notarius'
  s.license = 'MIT'

  s.add_development_dependency 'rake', '~> 0.9.2'
  s.add_development_dependency 'rspec', '~> 2.10'

  s.files = `git ls-files`.split("\n")
  s.files.reject! { |file| file =~ /^\./ }

  s.test_files = `git ls-files -- spec/*_spec.rb`.split("\n")
end
