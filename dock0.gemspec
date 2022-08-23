require 'English'
$LOAD_PATH.unshift File.expand_path('lib', __dir__)
require 'dock0/version'

Gem::Specification.new do |s|
  s.name        = 'dock0'
  s.version     = Dock0::VERSION
  s.date        = Time.now.strftime('%Y-%m-%d')

  s.summary     = 'Builds a read-only Arch host for Docker'
  s.description = 'Generates a read-only Arch host for running Docker containers' # rubocop:disable Metrics/LineLength
  s.authors     = ['Les Aker']
  s.email       = 'me@lesaker.org'
  s.homepage    = 'https://github.com/aker/dock0'
  s.license     = 'MIT'

  s.files       = `git ls-files`.split
  s.test_files  = `git ls-files spec/*`.split
  s.executables = ['dock0']

  s.add_dependency 'cymbal', '~> 2.0.0'
  s.add_dependency 'meld', '~> 1.1.0'
  s.add_dependency 'menagerie', '~> 1.1.1'
  s.add_dependency 'mercenary', '~> 0.3.4'

  s.add_development_dependency 'codecov', '~> 0.1.1'
  s.add_development_dependency 'fuubar', '~> 2.5.0'
  s.add_development_dependency 'gem-release', '~> 2.2.2'
  s.add_development_dependency 'goodcop', '~> 0.8.0'
  s.add_development_dependency 'rake', '~> 13.0.0'
  s.add_development_dependency 'rspec', '~> 3.9.0'
  s.add_development_dependency 'rubocop', '~> 0.76.0'
end
