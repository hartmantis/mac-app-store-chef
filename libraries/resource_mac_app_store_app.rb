# Encoding: UTF-8
#
# Cookbook Name:: mac-app-store
# Library:: resource_mac_app_store_app
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

require 'chef/resource/lwrp_base'

class Chef
  class Resource
    # A Chef resource for Mac App Store applications.
    #
    # @author Jonathan Hartman <j@p4nt5.com>
    class MacAppStoreApp < Resource::LWRPBase
      self.resource_name = :mac_app_store_app
      actions :install
      default_action :install

      #
      # Attribute for the app's installed status.
      #
      attribute :installed,
                kind_of: [NilClass, TrueClass, FalseClass],
                default: nil
      alias_method :installed?, :installed

      #
      # The name of the app to be installed (defaults to the resource name).
      #
      attribute :app_name, kind_of: String, name_attribute: true

      #
      # Timeout value for app download + install.
      #
      attribute :timeout, kind_of: Fixnum, default: 600

      #
      # An optional bundle identifier for the app, as seen in the package-id
      # field in the output of `pkgutil --pkg-info`. If one is provided, it
      # makes checking the installed status of an app much easier--it can be
      # be done by shelling out to pkgutil instead of having to wait for
      # multiple App Store page loads.
      #
      attribute :bundle_id, kind_of: String, default: nil
    end
  end
end
