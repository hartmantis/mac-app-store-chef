# Encoding: UTF-8

source 'https://rubygems.org'

group :development do
  gem 'yard-chef'
  gem 'guard'
  gem 'guard-foodcritic'
  gem 'guard-rspec'
  gem 'guard-kitchen'
end

group :test do
  gem 'rake'
  gem 'cane'
  gem 'countloc'
  gem 'rubocop'
  gem 'foodcritic'
  gem 'rspec', '>= 3'
  gem 'chefspec', '>= 4'
  gem 'simplecov'
  gem 'simplecov-console'
  gem 'coveralls'
  gem 'fauxhai'
  gem 'test-kitchen'
  gem 'kitchen-digitalocean', '>= 0.8.0'
  # TODO: Depends on https://github.com/test-kitchen/kitchen-vagrant/pull/121
  # (merged on 11/10/2014 but not yet released as of 01/29/2015)
  gem 'kitchen-vagrant', github: 'test-kitchen/kitchen-vagrant'
end

group :integration do
  gem 'serverspec', '>= 2'
  gem 'cucumber'
end

group :deploy do
  gem 'stove'
end

group :production do
  gem 'chef', '>= 11'
  gem 'berkshelf', '>= 3'
  gem 'AXElements', '>= 6'
end
