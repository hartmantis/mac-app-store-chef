# Encoding: UTF-8

require_relative '../spec_helper'
require_relative '../../libraries/provider_mapping'

describe :provider_mapping do
  let(:platform) { nil }
  let(:provider) do
    Chef::Platform.platforms[platform][:default][:mac_app_store_app]
  end

  context 'Mac OS X' do
    let(:platform) { :mac_os_x }

    it 'returns the MacAppStoreApp provider' do
      expect(provider).to eq(Chef::Provider::MacAppStoreApp)
    end
  end

  context 'Mac OS X Server' do
    let(:platform) { :mac_os_x_server }

    it 'returns the MacAppStoreApp provider' do
      expect(provider).to eq(Chef::Provider::MacAppStoreApp)
    end
  end

  context 'Ubuntu' do
    let(:platform) { :ubuntu }

    it 'returns no provider' do
      expect(provider).to eq(nil)
    end
  end
end
