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

  describe 'AXE_VERSION' do
    it 'pins AXE to 7 prerelease' do
      expect(described_class::AXE_VERSION).to eq('~> 7.0')
    end
  end

  describe '#whyrun_supported?' do
    it 'returns true' do
      expect(provider.whyrun_supported?).to eq(true)
    end
  end

  describe '#original_focus' do
    it 'returns the app originally focused on' do
      p = provider
      p.instance_variable_set(:@original_focus, 'focused app')
      expect(p.original_focus).to eq('focused app')
    end
  end

  describe '#load_current_resource' do
    let(:app_store_running?) { true }

    before(:each) do
      allow_any_instance_of(described_class).to receive(:app_store_running?)
        .and_return(app_store_running?)
    end

    it 'returns a MacAppStore resource instance' do
      expected = Chef::Resource::MacAppStore
      expect(provider.load_current_resource).to be_an_instance_of(expected)
    end

    it 'sets the resource running status' do
      p = provider
      p.load_current_resource
      expect(p.current_resource.running?).to eq(true)
    end
  end

  describe '#action_open' do
    let(:focused_application) { 'some app' }

    before(:each) do
      [:prep, :open_app_store, :sign_in!].each do |m|
        allow_any_instance_of(described_class).to receive(m)
      end
      allow(AX::SystemWide).to receive(:new)
        .and_return(double(focused_application: focused_application))
    end

    [:prep, :open_app_store].each do |m|
      it "calls #{m}" do
        expect_any_instance_of(described_class).to receive(m)
        provider.action_open
      end
    end

    it 'saves the original target of system focus' do
      p = provider
      p.action_open
      expect(p.original_focus).to eq('some app')
    end

    it 'signs in' do
      expect_any_instance_of(described_class).to receive(:sign_in!)
        .with(username, password)
      provider.action_open
    end

    it 'sets the resource running state' do
      p = provider
      p.action_open
      expect(p.new_resource.running?).to eq(true)
    end
  end

  describe '#action_quit' do
    let(:original_focus) { nil }

    before(:each) do
      [:prep, :quit_app_store, :set_focus_to].each do |m|
        allow_any_instance_of(described_class).to receive(m)
      end
      allow_any_instance_of(described_class).to receive(:original_focus)
        .and_return(original_focus)
    end

    shared_examples_for 'any prior state' do
      [:prep, :quit_app_store].each do |m|
        it "calls #{m}" do
          expect_any_instance_of(described_class).to receive(m)
          provider.action_quit
        end
      end

      it 'sets the resource running state' do
        p = provider
        p.action_quit
        expect(p.new_resource.running?).to eq(false)
      end
    end

    context 'no saved original focus' do
      let(:original_focus) { nil }

      it_behaves_like 'any prior state'

      it 'does not reset focus' do
        expect_any_instance_of(described_class).not_to receive(:set_focus_to)
        provider.action_quit
      end
    end

    context 'a saved original focus' do
      let(:original_focus) { 'thing' }

      it_behaves_like 'any prior state'

      it 'resets focus' do
        expect_any_instance_of(described_class).to receive(:set_focus_to)
          .with('thing')
        provider.action_quit
      end
    end
  end

  describe '#quit_app_store' do
    let(:app_store_running?) { nil }

    before(:each) do
      allow_any_instance_of(described_class).to receive(:app_store_running?)
        .and_return(app_store_running?)
      allow_any_instance_of(described_class).to receive(:quit!)
    end

    context 'App Store not running' do
      let(:app_store_running?) { false }

      it 'does nothing' do
        p = provider
        expect(p).not_to receive(:quit!)
        p.send(:quit_app_store)
        expect(p.new_resource.updated).to eq(false)
      end
    end

    context 'App Store running' do
      let(:app_store_running?) { true }

      it 'quits' do
        p = provider
        expect(p).to receive(:quit!)
        p.send(:quit_app_store)
        expect(p.new_resource.updated).to eq(true)
      end
    end
  end

  describe '#open_app_store' do
    let(:app_store_running?) { nil }

    before(:each) do
      allow_any_instance_of(described_class).to receive(:app_store_running?)
        .and_return(app_store_running?)
      allow_any_instance_of(described_class).to receive(:app_store)
    end

    context 'App Store not running' do
      let(:app_store_running?) { false }

      it 'opens the App Store' do
        p = provider
        expect(p).to receive(:app_store)
        p.send(:open_app_store)
        expect(p.new_resource.updated).to eq(true)
      end
    end

    context 'App Store running' do
      let(:app_store_running?) { true }

      it 'changes focus to the App Store' do
        p = provider
        expect(p).to receive(:app_store)
        p.send(:open_app_store)
        expect(p.new_resource.updated).to eq(false)
      end
    end
  end

  describe '#prep' do
    it 'installs Xcode and AXE and sets up Accessibility rights' do
      p = provider
      expect(p).to receive(:install_xcode_tools)
      expect(p).to receive(:install_axe_gem)
      expect(p).to receive(:trust_app)
      p.send(:prep)
    end
  end

  describe '#trust_app' do
    let(:current_application_name) { 'com.example.app' }
    let(:psm_resource) { double(run_action: true) }

    before(:each) do
      allow_any_instance_of(described_class)
        .to receive(:current_application_name)
        .and_return(current_application_name)
    end

    it 'grants accessibility rights to the current running application' do
      p = provider
      expect(p).to receive(:include_recipe_now)
        .with('privacy_services_manager')
      expect(p).to receive(:privacy_services_manager)
        .with("Grant Accessibility rights to #{current_application_name}")
        .and_yield
      expect(p).to receive(:service).with('accessibility')
      expect(p).to receive(:applications).with([current_application_name])
      expect(p).to receive(:admin).with(true)
        .and_return(psm_resource)
      expect(psm_resource).to receive(:run_action).with(:add)
      p.send(:trust_app)
    end
  end

  describe '#install_axe_gem' do
    let(:chef_gem_resource) { double(run_action: true) }

    it 'installs the AXElements gem' do
      p = provider
      expect(p).to receive(:chef_gem).with('AXElements').and_yield
      expect(p).to receive(:compile_time).with(false)
      expect(p).to receive(:version).with('~> 7.0')
        .and_return(chef_gem_resource)
      expect(chef_gem_resource).to receive(:run_action).with(:install)
      p.send(:install_axe_gem)
    end
  end

  describe '#install_xcode_tools' do
    let(:xcode_command_line_tools_resource) { double(run_action: true) }

    it 'installs the Xcode command line tools' do
      p = provider
      expect(p).to receive(:xcode_command_line_tools).with('default')
        .and_return(xcode_command_line_tools_resource)
      expect(xcode_command_line_tools_resource).to receive(:run_action)
        .with(:install)
      p.send(:install_xcode_tools)
    end
  end
end
