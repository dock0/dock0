Gem::Specification.new do |s|
  s.name        = 'dock0'
  s.version     = '0.0.4'
  s.date        = Time.now.strftime("%Y-%m-%d")

  s.summary     = 'Builds a read-only Arch host for Docker'
  s.description = "Generates a read-only Arch host for running Docker containers"
  s.authors     = ['Les Aker']
  s.email       = 'me@lesaker.org'
  s.homepage    = 'https://github.com/aker/dock0'
  s.license     = 'MIT'

  s.files       = `git ls-files`.split
  s.test_files  = `git ls-files spec/*`.split
  s.executables = ['dock0']

  s.add_development_dependency 'rubocop'
  s.add_development_dependency 'travis-lint'
  s.add_development_dependency 'rake'
  s.add_development_dependency 'fuubar'
end
