# Encoding: UTF-8
#
# Cookbook Name:: mac-app-store
# Recipe:: default
#
# Copyright 2015-2016, Jonathan Hartman
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

unless node['platform'] == 'mac_os_x'
  raise(Chef::Exceptions::UnsupportedPlatform, node['platform'])
end

mac_app_store_mas 'default' do
  username node['mac_app_store']['username']
  password node['mac_app_store']['password']
  unless node['mac_app_store']['mas']['source'].nil?
    source node['mac_app_store']['mas']['source']
  end
  unless node['mac_app_store']['mas']['version'].nil?
    version node['mac_app_store']['mas']['version']
  end
  unless node['mac_app_store']['mas']['system_user'].nil?
    system_user node['mac_app_store']['mas']['system_user']
  end
  action %i(install sign_in)
end

node['mac_app_store']['apps'].to_h.each do |k, v|
  next unless v == true
  mac_app_store_app k do
    unless node['mac_app_store']['mas']['system_user'].nil?
      system_user node['mac_app_store']['mas']['system_user']
    end
  end
end
