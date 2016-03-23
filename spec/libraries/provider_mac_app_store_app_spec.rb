# Encoding: UTF-8

require 'ax_elements'
require_relative '../spec_helper'
require_relative '../../libraries/provider_mac_app_store_app'

describe Chef::Provider::MacAppStoreApp do
  let(:name) { 'Some App' }
  %i(app_name timeout bundle_id).each { |a| let(a) { nil } }
  let(:timeout) { nil }
  let(:bundle_id) { nil }
  let(:run_context) { ChefSpec::SoloRunner.new.converge.run_context }
  let(:new_resource) do
    r = Chef::Resource::MacAppStoreApp.new(name, run_context)
    %i(app_name timeout bundle_id).each do |a|
      r.send(a, send(a)) unless send(a).nil?
    end
    r
  end
  let(:provider) { described_class.new(new_resource, run_context) }

  describe '.provides?' do
    let(:platform) { nil }
    let(:node) { ChefSpec::Macros.stub_node('node.example', platform) }
    let(:res) { described_class.provides?(node, new_resource) }

    context 'Mac OS X' do
      let(:platform) { { platform: 'mac_os_x', version: '10.10' } }

      it 'returns true' do
        expect(res).to eq(true)
      end
    end
  end

  describe '#whyrun_supported?' do
    it 'returns true' do
      expect(provider.whyrun_supported?).to eq(true)
    end
  end

  describe '#load_current_resource' do
    let(:installed?) { true }

    before(:each) do
      allow_any_instance_of(described_class).to receive(:installed?)
        .and_return(installed?)
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
    let(:installed?) { false }
    let(:current_resource) { double(installed?: installed?) }

    before(:each) do
      allow_any_instance_of(described_class).to receive(:current_resource)
        .and_return(current_resource)
      allow_any_instance_of(described_class).to receive(:install!)
        .with(name, timeout || 600).and_return(true)
    end

    shared_examples_for 'any installed state' do
      it 'sets installed state to true' do
        expect(new_resource).to receive(:installed).with(true)
        provider.action_install
      end
    end

    context 'not already installed' do
      let(:installed?) { false }

      it_behaves_like 'any installed state'

      it 'installs the app' do
        expect_any_instance_of(described_class).to receive(:install!)
          .with(name, 600)
        provider.action_install
      end
    end

    context 'already installed' do
      let(:installed?) { true }

      it_behaves_like 'any installed state'

      it 'does not install the app' do
        expect_any_instance_of(described_class).not_to receive(:install!)
        provider.action_install
      end
    end

    context 'an overridden app_name' do
      let(:app_name) { 'somethingelse' }
      let(:installed?) { false }

      it 'installs the app_name instead of the resource name' do
        expect_any_instance_of(described_class).to receive(:install!)
          .with(app_name, 600)
        provider.action_install
      end
    end
  end

  describe '#installed?' do
    let(:installed?) { false }
    let(:shell_out) { double(error?: !installed?) }

    before(:each) do
      allow_any_instance_of(described_class).to receive(:shell_out)
        .with("pkgutil --pkg-info #{bundle_id}").and_return(shell_out)
      allow_any_instance_of(described_class).to receive(:app_installed?)
        .with(name).and_return(installed?)
    end

    context 'no bundle ID provided' do
      let(:bundle_id) { nil }

      it 'uses the App Store helper method' do
        expect_any_instance_of(described_class).not_to receive(:shell_out)
        expect_any_instance_of(described_class).to receive(:app_installed?)
          .with(name)
        provider.send(:installed?)
      end

      context 'app not installed' do
        let(:installed?) { false }

        it 'returns false' do
          expect(provider.send(:installed?)).to eq(false)
        end
      end

      context 'app installed' do
        let(:installed?) { true }

        it 'returns true' do
          expect(provider.send(:installed?)).to eq(true)
        end
      end

      context 'installed and an overridden app_name' do
        let(:installed?) { true }
        let(:app_name) { 'somethingelse' }

        it 'checks the app_name instead of resource name' do
          expect_any_instance_of(described_class)
            .not_to receive(:app_installed?).with(name)
          expect_any_instance_of(described_class).to receive(:app_installed?)
            .with(app_name).and_return(installed?)
          expect(provider.send(:installed?)).to eq(true)
        end
      end
    end

    context 'bundle ID provided' do
      let(:bundle_id) { 'com.example.someapp' }

      it 'uses pkgutil' do
        expect_any_instance_of(described_class).to receive(:shell_out)
          .with("pkgutil --pkg-info #{bundle_id}")
        expect_any_instance_of(described_class).not_to receive(:app_installed?)
        provider.send(:installed?)
      end

      context 'app not installed' do
        let(:installed?) { false }

        it 'returns false' do
          expect(provider.send(:installed?)).to eq(false)
        end
      end

      context 'app installed' do
        let(:installed?) { true }

        it 'returns true' do
          expect(provider.send(:installed?)).to eq(true)
        end
      end
    end
  end
end
