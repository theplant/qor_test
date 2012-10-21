require 'rake'
require 'rubygems/package_task'
require 'rake/testtask'
require "bundler/gem_tasks"

Rake::TestTask.new(:test) do |t|
  t.libs << 'lib'
  t.libs << 'test'
  t.pattern = 'test/**/*_test.rb'
  t.verbose = false
end

task :default => :test
