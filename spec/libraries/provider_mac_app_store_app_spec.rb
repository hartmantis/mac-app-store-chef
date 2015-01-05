# Encoding: UTF-8

require_relative '../spec_helper'
require_relative '../../libraries/provider_mac_app_store_app'

describe Chef::Provider::MacAppStoreApp do
  let(:platform) { { platform: 'mac_os_x', version: '10.9.2' } }
  let(:node) { Fauxhai.mock(platform).data }
  let(:app_name) { 'Some App' }
  let(:app_id) { 'com.example.someapp' }
  let(:new_resource) do
    r = Chef::Resource::MacAppStoreApp.new(app_name, nil)
    r.app_id(app_id)
    r
  end
  let(:provider) { described_class.new(new_resource, nil) }

  before(:each) do
    allow_any_instance_of(described_class).to receive(:node).and_return(node)
  end

  describe '#whyrun_supported?' do
    it 'returns true' do
      expect(provider.whyrun_supported?).to eq(true)
    end
  end

  describe '#load_current_resource' do
    it 'returns a MacAppStoreApp resource instance' do
      expected = Chef::Resource::MacAppStoreApp
      expect(provider.load_current_resource).to be_an_instance_of(expected)
    end
  end

  describe '#action_install' do
    [:axe_gem].each do |r|
      let(r) { double(run_action: true) }
    end

    before(:each) do
      [:axe_gem].each do |r|
        allow_any_instance_of(described_class).to receive(r).and_return(send(r))
      end
    end

    it 'installs the AXE gem' do
      expect(axe_gem).to receive(:run_action).with(:install)
      provider.action_install
    end

    it 'sets installed state to true' do
      expect(new_resource).to receive(:'installed=').with(true)
      provider.action_install
    end
  end

  describe '#axe_gem' do
    it 'returns a chef_gem resource' do
      expected = Chef::Resource::ChefGem
      expect(provider.send(:axe_gem)).to be_an_instance_of(expected)
    end

    it 'uses AXE 6' do
      expect(provider.send(:axe_gem).version).to eq('~> 6.0')
    end
  end
end
