# Encoding: UTF-8

require_relative '../spec_helper'
require_relative '../../libraries/provider_mapping'

describe :provider_mapping do
  let(:platform) { nil }
  let(:app_store_provider) do
    Chef::Platform.platforms[platform][:default][:mac_app_store]
  end
  let(:app_provider) do
    Chef::Platform.platforms[platform][:default][:mac_app_store_app]
  end

  context 'Mac OS X' do
    let(:platform) { :mac_os_x }

    it 'uses the MacAppStore App Store program provider' do
      expect(app_store_provider).to eq(Chef::Provider::MacAppStore)
    end

    it 'uses the MacAppStoreApp app provider' do
      expect(app_provider).to eq(Chef::Provider::MacAppStoreApp)
    end
  end

  context 'Ubuntu' do
    let(:platform) { :ubuntu }

    it 'returns no App Store program provider' do
      expect(app_store_provider).to eq(nil)
    end

    it 'returns no app provider' do
      expect(app_provider).to eq(nil)
    end
  end
end
