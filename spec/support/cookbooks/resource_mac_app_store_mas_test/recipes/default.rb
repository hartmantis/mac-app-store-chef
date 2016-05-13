# Encoding: UTF-8

attrs = node['resource_mac_app_store_mas_test']

mac_app_store_mas attrs['name'] do
  install_method attrs['install_method'] unless attrs['install_method'].nil?
  version attrs['version'] unless attrs['version'].nil?
  username attrs['username'] unless attrs['username'].nil?
  password attrs['password'] unless attrs['password'].nil?
  action attrs['action'] unless attrs['action'].nil?
end
