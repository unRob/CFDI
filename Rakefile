require "bundler/gem_tasks"
require 'rspec/core/rake_task'

task :release do
  system "gem build cfdi.gemspec"
end

RSpec::Core::RakeTask.new(:spec) do |t|
  t.pattern = 'test/*_spec.rb'
end

task :test => :spec