# encoding: utf-8
# frozen_string_literal: true

source 'https://rubygems.org'

group :development do
  gem 'guard'
  gem 'guard-foodcritic'
  gem 'guard-kitchen'
  gem 'guard-rspec'
  gem 'yard-chef'
end

group :test do
  gem 'chefspec'
  gem 'coveralls'
  gem 'fauxhai'
  gem 'foodcritic'
  gem 'kitchen-localhost'
  gem 'kitchen-vagrant'
  gem 'rake'
  gem 'rspec'
  gem 'rubocop'
  gem 'simplecov'
  gem 'simplecov-console'
  gem 'test-kitchen'
end

group :integration do
  gem 'serverspec'
end

group :deploy do
  gem 'stove'
end

group :production do
  gem 'berkshelf'
  gem 'chef', '>= 12'
end
