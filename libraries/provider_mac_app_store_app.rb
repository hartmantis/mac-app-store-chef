# Encoding: UTF-8
#
# Cookbook Name:: mac-app-store
# Library:: provider_mac_app_store_app
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

require 'chef/provider/lwrp_base'
require 'chef/mixin/shell_out'
require_relative 'helpers'
require_relative 'resource_mac_app_store_app'

class Chef
  class Provider
    # A Chef provider for Mac App Store apps
    #
    # @author Jonathan Hartman <j@p4nt5.com>
    class MacAppStoreApp < Provider::LWRPBase
      include MacAppStoreCookbook::Helpers
      include Chef::Mixin::ShellOut

      #
      # WhyRun is supported by this provider
      #
      # @return [TrueClass, FalseClass]
      #
      def whyrun_supported?
        true
      end

      #
      # Load and return the current resource
      #
      # @return [Chef::Resource::MacAppStoreApp]
      #
      def load_current_resource
        @current_resource ||= Resource::MacAppStoreApp.new(new_resource.name)
        @current_resource.installed(installed?)
        @current_resource
      end

      #
      # Install the app from the Mac App Store
      #
      action :install do
        unless current_resource.installed?
          install!(new_resource.name, new_resource.timeout)
          new_resource.updated_by_last_action(true)
        end
        new_resource.installed(true)
      end

      private

      #
      # Check whether the resource app is installed. If a bundle ID was
      # provided, shell out to pkgutil. Otherwise, fall back to the helper
      # method that is much slower and has to do multiple page loads in the
      # App Store UI.
      #
      # @return [TrueClass, FalseClass]
      #
      def installed?
        if new_resource.bundle_id
          !shell_out("pkgutil --pkg-info #{new_resource.bundle_id}").error?
        else
          app_installed?(new_resource.name)
        end
      end
    end
  end
end
