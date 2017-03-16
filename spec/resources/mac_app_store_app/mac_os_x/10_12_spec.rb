# encoding: utf-8
# frozen_string_literal: true

require_relative '../mac_os_x'

describe 'resources::mac_app_store_app::mac_os_x::10_12' do
  include_context 'resources::mac_app_store_app::mac_os_x'

  let(:platform_version) { '10.12' }

  it_behaves_like 'any MacOS platform'
end
