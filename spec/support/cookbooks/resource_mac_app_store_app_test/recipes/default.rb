# Encoding: UTF-8

attrs = node['resource_mac_app_store_app_test']

mac_app_store_app attrs['name'] do
  app_name attrs['app_name'] unless attrs['app_name'].nil?
  system_user attrs['system_user'] unless attrs['system_user'].nil?
  action attrs['action'] unless attrs['action'].nil?
end
