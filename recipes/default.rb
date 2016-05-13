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
  action %i(install sign_in)
end

node['mac_app_store']['apps'].to_a.each do |a|
  mac_app_store_app a
end
