require 'English'
$LOAD_PATH.unshift File.expand_path('lib', __dir__)
require 'dock0/version'

Gem::Specification.new do |s|
  s.name        = 'dock0'
  s.version     = Dock0::VERSION

  s.required_ruby_version = '>= 3.0'

  s.summary     = 'Builds a read-only Arch host for Docker'
  s.description = 'Generates a read-only Arch host for running Docker containers'
  s.authors     = ['Les Aker']
  s.email       = 'me@lesaker.org'
  s.homepage    = 'https://github.com/aker/dock0'
  s.license     = 'MIT'

  s.files       = `git ls-files`.split
  s.executables = ['dock0']

  s.add_dependency 'cymbal', '~> 2.0.0'
  s.add_dependency 'meld', '~> 1.1.0'
  s.add_dependency 'menagerie', '~> 1.1.1'
  s.add_dependency 'mercenary', '~> 0.4.0'

  s.add_development_dependency 'goodcop', '~> 0.9.7'
  s.metadata['rubygems_mfa_required'] = 'true'
end
