# Encoding: UTF-8

require 'ax_elements'
require_relative '../spec_helper'
require_relative '../../libraries/provider_mac_app_store'

describe Chef::Provider::MacAppStore do
  let(:username) { 'auser' }
  let(:password) { 'apassword' }
  let(:system_wide) { double(focused_application: 'focused app') }
  let(:app_store_running?) { false }
  let(:sign_in!) { true }
  let(:new_resource) do
    r = Chef::Resource::MacAppStore.new(nil)
    %i(username password).each do |m|
      r.send(m, send(m))
    end
    r
  end
  let(:provider) { described_class.new(new_resource, nil) }

  before(:each) do
    %i(install_axe_gem trust_app).each do |m|
      allow_any_instance_of(described_class).to receive(m).and_return(true)
    end
    allow(AX::SystemWide).to receive(:new).and_return(system_wide)
    allow_any_instance_of(described_class).to receive(:app_store_running?)
      .and_return(app_store_running?)
  end

  describe 'AXE_VERSION' do
    it 'pins AXE to 6.x' do
      expect(described_class::AXE_VERSION).to eq('~> 6.0')
    end
  end

  describe '#whyrun_supported?' do
    it 'returns true' do
      expect(provider.whyrun_supported?).to eq(true)
    end
  end

  describe '#original_focus' do
    it 'returns the app originally focused on' do
      expect(provider.original_focus).to eq('focused app')
    end
  end

  describe '#initialize' do
    shared_examples_for 'any initial state' do
      it 'installs the AXE gem' do
        expect_any_instance_of(described_class).to receive(:install_axe_gem)
        provider
      end

      it 'sets up accessibility for the app running Chef' do
        expect_any_instance_of(described_class).to receive(:trust_app)
        provider
      end

      it 'saves the original focused app for later' do
        expect(provider.original_focus).to eq('focused app')
      end
    end
  end

  describe '#load_current_resource' do
    let(:app_store_running?) { true }

    it 'returns a MacAppStore resource instance' do
      expected = Chef::Resource::MacAppStore
      expect(provider.load_current_resource).to be_an_instance_of(expected)
    end

    it 'sets the resource running status' do
      expect(provider.load_current_resource.running?).to eq(true)
    end
  end

  describe '#action_open' do
    let(:app_store_running?) { false }
    let(:app_store) { 'app store' }

    before(:each) do
      allow_any_instance_of(described_class).to receive(:app_store)
        .and_return(app_store)
      allow_any_instance_of(described_class).to receive(:set_focus_to)
        .with(app_store).and_return(true)
      allow_any_instance_of(described_class).to receive(:sign_in!)
        .with(username, password).and_return(true)
    end

    it 'sets focus to the App Store' do
      expect_any_instance_of(described_class).to receive(:set_focus_to)
        .with(app_store)
      provider.action_open
    end

    it 'signs in as the provided Apple ID' do
      expect_any_instance_of(described_class).to receive(:sign_in!)
        .with(username, password)
      provider.action_open
    end

    it 'sets the resource running status' do
      p = provider
      expect(p.new_resource.running?).to eq(nil)
      p.action_open
      expect(p.new_resource.running?).to eq(true)
    end
  end

  describe '#action_quit' do
    let(:app_store_running?) { true }

    before(:each) do
      allow_any_instance_of(described_class).to receive(:quit!)
        .and_return(true)
      allow_any_instance_of(described_class).to receive(:set_focus_to)
        .with('focused app').and_return(true)
    end

    it 'quits the App Store' do
      expect_any_instance_of(described_class).to receive(:quit!)
      provider.action_quit
    end

    it 'returns focus to the original target' do
      expect_any_instance_of(described_class).to receive(:set_focus_to)
        .with('focused app')
      provider.action_quit
    end

    it 'sets the resource running status' do
      p = provider
      expect(p.new_resource.running?).to eq(nil)
      p.action_quit
      expect(p.new_resource.running?).to eq(false)
    end
  end

  describe '#trust_app' do
    let(:current_application_name) { 'com.example.app' }

    before(:each) do
      allow_any_instance_of(described_class).to receive(:trust_app)
        .and_call_original
      allow_any_instance_of(described_class)
        .to receive(:mac_app_store_trusted_app).and_return(true)
      allow_any_instance_of(described_class)
        .to receive(:current_application_name)
        .and_return(current_application_name)
    end

    it 'grants accessibility rights to the current running application' do
      p = provider
      expect(p).to receive(:mac_app_store_trusted_app)
        .with(current_application_name).and_yield
      expect(p).to receive(:compile_time).with(true)
      expect(p).to receive(:action).with(:create)
      p.send(:trust_app)
    end
  end

  describe '#install_axe_gem' do
    let(:chef_gem) { double(version: true, action: true) }

    before(:each) do
      allow_any_instance_of(described_class).to receive(:chef_gem)
        .with('AXElements').and_yield
    end

    it 'installs the AXElements gem' do
      p = provider
      allow(p).to receive(:install_axe_gem).and_call_original
      expect(p).to receive(:compile_time).with(true)
      expect(p).to receive(:version).with('~> 6.0')
      expect(p).to receive(:action).with(:install)
      p.send(:install_axe_gem)
    end
  end
end
