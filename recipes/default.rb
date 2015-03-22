# Encoding: UTF-8
#
# Cookbook Name:: mac-app-store
# Recipe:: default
#
# Copyright 2015 Jonathan Hartman
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
  fail(Chef::Exceptions::UnsupportedPlatform, node['platform'])
end

include_recipe 'build-essential'

apps = node['mac_app_store'] && node['mac_app_store']['apps'] || []

apps.each do |a|
  mac_app_store_app a do
    username node['mac_app_store']['username']
    password node['mac_app_store']['password']
  end
end
