# frozen_string_literal: true

mac_app_store_mas do
  username node['mac_app_store']['username']
  password node['mac_app_store']['password']
end

mac_app_store_app 'Microsoft Remote Desktop'
mac_app_store_app 'White Noise Free'
