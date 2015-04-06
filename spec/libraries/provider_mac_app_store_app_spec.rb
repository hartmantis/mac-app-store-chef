# Encoding: UTF-8

require 'ax_elements'
require_relative '../spec_helper'
require_relative '../../libraries/provider_mac_app_store_app'

describe Chef::Provider::MacAppStoreApp do
  let(:app_name) { 'Some App' }
  let(:timeout) { nil }
  let(:new_resource) do
    r = Chef::Resource::MacAppStoreApp.new(app_name, nil)
    r.timeout(timeout)
    r
  end
  let(:provider) { described_class.new(new_resource, nil) }

  describe '#whyrun_supported?' do
    it 'returns true' do
      expect(provider.whyrun_supported?).to eq(true)
    end
  end

  describe '#load_current_resource' do
    let(:app_installed?) { true }

    before(:each) do
      allow_any_instance_of(described_class).to receive(:app_installed?)
        .with(app_name).and_return(app_installed?)
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
        .with(app_name, timeout || 600).and_return(true)
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
          .with(app_name, 600)
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
  end
end
