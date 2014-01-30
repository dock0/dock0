require 'bundler/gem_tasks'
require 'rubocop/rake_task'

desc 'Update bundle'
task :bundle do
  `bundle update`
end

desc 'Run Rubocop on the gem'
Rubocop::RakeTask.new(:rubocop) do |task|
  task.patterns = ['lib/**/*.rb', 'spec/*.rb', 'spec/helpers/*.rb', 'bin/*']
  task.fail_on_error = true
end

desc 'Run travis-lint on .travis.yml'
task :travislint do
  print 'There is an issue with your .travis.yml' unless system('travis-lint')
end

task default: [:travislint, :rubocop, :build]
task release: [:bundle]
