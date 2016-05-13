# Encoding: UTF-8

attrs = node['resource_mac_app_store_app_test']

mac_app_store_app attrs['name'] do
  app_name attrs['app_name'] unless attrs['app_name'].nil?
  action attrs['action'] unless attrs['action'].nil?
end
