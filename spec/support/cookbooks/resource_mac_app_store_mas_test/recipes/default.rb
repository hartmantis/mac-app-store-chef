# Encoding: UTF-8

attrs = node['resource_mac_app_store_mas_test']

mac_app_store_mas attrs['name'] do
  source attrs['source'] unless attrs['source'].nil?
  version attrs['version'] unless attrs['version'].nil?
  username attrs['username'] unless attrs['username'].nil?
  password attrs['password'] unless attrs['password'].nil?
  system_user attrs['system_user'] unless attrs['system_user'].nil?
  action attrs['action'] unless attrs['action'].nil?
end
