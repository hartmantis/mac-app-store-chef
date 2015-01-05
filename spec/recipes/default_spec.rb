# Encoding: UTF-8

require 'spec_helper'

describe 'mac-app-store::default' do
  let(:platform) { { platform: 'ubuntu', version: '14.04' } }
  let(:runner) { ChefSpec::ServerRunner.new(platform) }
  let(:chef_run) { runner.converge(described_recipe) }

  it 'converges successfully' do
    expect(chef_run).to be
  end
end
