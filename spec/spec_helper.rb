# Encoding: UTF-8

require 'chef'
require 'chefspec'
require 'json'
require 'tempfile'
require 'simplecov'
require 'simplecov-console'
require 'coveralls'
require 'tmpdir'
require 'fileutils'

RSpec.configure do |c|
  c.color = true

  c.before(:suite) do
    COOKBOOK_PATH = Dir.mktmpdir('chefspec')
    metadata = Chef::Cookbook::Metadata.new
    metadata.from_file(File.expand_path('../../metadata.rb', __FILE__))
    link_path = File.join(COOKBOOK_PATH, metadata.name)
    FileUtils.ln_s(File.expand_path('../..', __FILE__), link_path)
    c.cookbook_path = COOKBOOK_PATH
  end

  c.before(:each) do
    # Don't worry about external cookbook dependencies
    allow_any_instance_of(Chef::Cookbook::Metadata).to receive(:depends)

    # Prep lookup() for the stubs below
    allow_any_instance_of(Chef::ResourceCollection).to receive(:lookup)
      .and_call_original

    # Test each recipe in isolation, regardless of includes
    @included_recipes = []
    allow_any_instance_of(Chef::RunContext).to receive(:loaded_recipe?)
      .and_return(false)
    allow_any_instance_of(Chef::Recipe).to receive(:include_recipe) do |_, i|
      allow_any_instance_of(Chef::RunContext).to receive(:loaded_recipe?)
        .with(i)
        .and_return(true)
      @included_recipes << i
    end
    allow_any_instance_of(Chef::RunContext).to receive(:loaded_recipes)
      .and_return(@included_recipes)
  end

  c.after(:suite) { FileUtils.rm_r(COOKBOOK_PATH) }
end

SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter[
  Coveralls::SimpleCov::Formatter,
  SimpleCov::Formatter::HTMLFormatter,
  SimpleCov::Formatter::Console
]
SimpleCov.minimum_coverage 90
SimpleCov.start

at_exit { ChefSpec::Coverage.report! }
