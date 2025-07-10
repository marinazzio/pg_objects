require 'bundler/gem_tasks'
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec)

desc "Run performance benchmark"
task :benchmark do
  ruby "bin/benchmark"
end

task default: :spec
