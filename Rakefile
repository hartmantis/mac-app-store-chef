# Encoding: UTF-8

require 'rubygems'
require 'English'
require 'bundler/setup'
require 'rubocop/rake_task'
require 'cane/rake_task'
require 'rspec/core/rake_task'
require 'foodcritic'
require 'kitchen/rake_tasks'
require 'stove/rake_task'

Cane::RakeTask.new

RuboCop::RakeTask.new

desc 'Display LOC stats'
task :loc do
  puts "\n## LOC Stats"
  Kernel.system 'countloc -r .'
end

FoodCritic::Rake::LintTask.new do |f|
  f.options = { fail_tags: %w(any) }
end

RSpec::Core::RakeTask.new(:spec)

Kitchen::RakeTasks.new

Stove::RakeTask.new

task default: %w(cane rubocop loc foodcritic spec)
