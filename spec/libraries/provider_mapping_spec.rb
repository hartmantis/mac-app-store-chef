# Encoding: UTF-8

require_relative '../spec_helper'
require_relative '../../libraries/provider_mapping'

describe :provider_mapping do
  let(:platform) { nil }
  let(:app_provider) do
    Chef::Platform.platforms[platform][:default][:mac_app_store_app]
  end
  let(:trust_provider) do
    Chef::Platform.platforms[platform][:default][:mac_app_store_trusted_app]
  end

  context 'Mac OS X' do
    let(:platform) { :mac_os_x }

    it 'uses the MacAppStoreApp app provider' do
      expect(app_provider).to eq(Chef::Provider::MacAppStoreApp)
    end

    it 'uses the MacAppStoreTrustedApp trust provider' do
      expect(trust_provider).to eq(Chef::Provider::MacAppStoreTrustedApp)
    end
  end

  context 'Ubuntu' do
    let(:platform) { :ubuntu }

    it 'returns no app provider' do
      expect(app_provider).to eq(nil)
    end

    it 'returns no trust provider' do
      expect(trust_provider).to eq(nil)
    end
  end
end
