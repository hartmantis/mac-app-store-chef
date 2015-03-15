# Encoding: UTF-8

require 'ax_elements'
require_relative '../spec_helper'
require_relative '../../libraries/provider_mac_app_store_app'

describe Chef::Provider::MacAppStoreApp do
  let(:platform) { { platform: 'mac_os_x', version: '10.9.2' } }
  let(:node) { Fauxhai.mock(platform).data }
  let(:username) { 'auser' }
  let(:password) { 'apassword' }
  let(:app_name) { 'Some App' }
  let(:app_id) { 'com.example.someapp' }
  let(:timeout) { nil }
  let(:system_wide) { double(focused_application: 'something') }
  let(:running?) { false }
  let(:new_resource) do
    r = Chef::Resource::MacAppStoreApp.new(app_name, nil)
    %i(username password app_id timeout).each do |m|
      r.send(m, send(m))
    end
    r
  end
  let(:provider) { described_class.new(new_resource, nil) }

  before(:each) do
    %i(sleep install_axe_gem trust_app).each do |m|
      allow_any_instance_of(described_class).to receive(m).and_return(true)
    end
    allow_any_instance_of(described_class).to receive(:node).and_return(node)
    allow(AX::SystemWide).to receive(:new).and_return(system_wide)
    allow(MacAppStoreCookbook::Helpers).to receive(:running?)
      .and_return(running?)
  end

  describe 'AXE_VERSION' do
    it 'pins AXE to 6.x' do
      expect(Chef::Provider::MacAppStoreApp::AXE_VERSION).to eq('~> 6.0')
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
        expect(provider.original_focus).to eq('something')
      end
    end

    context 'App Store not running' do
      let(:running?) { false }

      it_behaves_like 'any initial state'

      it 'will quit the App Store when done' do
        expect(provider.quit_when_done?).to eq(true)
      end
    end

    context 'App Store running' do
      let(:running?) { true }

      it_behaves_like 'any initial state'

      it 'will leave the App Store open when done' do
        expect(provider.quit_when_done?).to eq(false)
      end
    end
  end

  describe '#whyrun_supported?' do
    it 'returns true' do
      expect(provider.whyrun_supported?).to eq(true)
    end
  end

  describe '#load_current_resource' do
    let(:installed) { true }

    before(:each) do
      allow_any_instance_of(described_class).to receive(:installed?)
        .and_return(installed)
    end

    it 'returns a MacAppStoreApp resource instance' do
      expected = Chef::Resource::MacAppStoreApp
      expect(provider.load_current_resource).to be_an_instance_of(expected)
    end

    it 'sets the resource installed status' do
      expect(provider.load_current_resource.installed?).to eq(true)
    end
  end

  describe '#action_install' do
    %i(
      installed?
      set_focus_to
      app_store
      sign_in!
      install!
      quit_when_done?
      original_focus
      quit!
    ).each do |i|
      let(i) { i }
    end

    before(:each) do
      %i(set_focus_to quit_when_done? original_focus).each do |r|
        allow_any_instance_of(described_class).to receive(r).and_return(send(r))
      end

      %i(installed? app_store sign_in! install! quit!).each do |r|
        allow(MacAppStoreCookbook::Helpers).to receive(r).and_return(send(r))
      end
    end

    shared_examples_for 'any installed state' do
      it 'sets installed state to true' do
        expect(new_resource).to receive(:installed).with(true)
        provider.action_install
      end
    end

    shared_examples_for 'quit when done' do
      it 'quits the App Store' do
        expect(MacAppStoreCookbook::Helpers).to receive(:quit!)
        provider.action_install
      end
    end

    shared_examples_for 'do not quit when done' do
      it 'does not quit the App Store' do
        expect(MacAppStoreCookbook::Helpers).not_to receive(:quit!)
        provider.action_install
      end
    end

    context 'not already installed' do
      let(:installed?) { false }

      it_behaves_like 'any installed state'

      it 'sets focus to the app store' do
        expect_any_instance_of(described_class).to receive(:set_focus_to)
          .with(app_store)
        provider.action_install
      end

      it 'signs the user in' do
        expect(MacAppStoreCookbook::Helpers).to receive(:sign_in!)
          .with(username, password)
        provider.action_install
      end

      it 'installs the app' do
        expect(MacAppStoreCookbook::Helpers).to receive(:install!)
          .with(app_name, 600)
        provider.action_install
      end

      context 'App Store not already running' do
        let(:quit_when_done?) { true }

        it_behaves_like 'quit when done'
      end

      context 'App Store already running' do
        let(:quit_when_done?) { false }

        it_behaves_like 'do not quit when done'
      end

      it 'sets focus back on the original app' do
        expect_any_instance_of(described_class).to receive(:set_focus_to)
          .with(original_focus)
        provider.action_install
      end
    end

    context 'already installed' do
      let(:installed?) { true }

      it_behaves_like 'any installed state'

      it 'does not do anything' do
        [:press, :sleep, :set_focus_to].each do |m|
          expect_any_instance_of(described_class).not_to receive(m)
        end
        provider.action_install
      end
    end
  end

  describe '#installed?' do
    let(:installed) { nil }
    let(:shell_out) { double(error?: !installed) }

    before(:each) do
      allow_any_instance_of(described_class).to receive(:shell_out)
        .with("pkgutil --pkg-info #{app_id}").and_return(shell_out)
    end

    context 'app installed' do
      let(:installed) { true }

      it 'returns true' do
        expect(provider.send(:installed?)).to eq(true)
      end
    end

    context 'app not installed' do
      let(:installed) { false }

      it 'returns false' do
        expect(provider.send(:installed?)).to eq(false)
      end
    end
  end

  describe '#trust_app' do
    it 'trusts sshd-keygen-wrapper' do
      p = provider
      allow(p).to receive(:trust_app).and_call_original
      expect(p).to receive(:mac_app_store_trusted_app)
        .with('/usr/libexec/sshd-keygen-wrapper').and_yield
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
