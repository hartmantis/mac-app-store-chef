# encoding: utf-8
# frozen_string_literal: true

require 'rubygems'
require 'bundler/setup'
require 'rubocop/rake_task'
require 'rspec/core/rake_task'
require 'foodcritic'
require 'kitchen/rake_tasks'
require 'stove/rake_task'

RuboCop::RakeTask.new

FoodCritic::Rake::LintTask.new do |f|
  f.options = { fail_tags: %w(any) }
end

RSpec::Core::RakeTask.new(:spec)

Kitchen::RakeTasks.new

Stove::RakeTask.new

task default: %w(rubocop foodcritic spec)
