# Encoding: UTF-8
#
# Cookbook Name:: mac-app-store
# Library:: provider_mac_app_store_app
#
# Copyright 2014 Jonathan Hartman
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

require 'chef/provider'
require 'chef/resource/chef_gem'
require_relative 'resource_mac_app_store_app'

class Chef
  class Provider
    # A Chef provider for Mac App Store apps
    #
    # @author Jonathan Hartman <j@p4nt5.com>
    class MacAppStoreApp < Provider
      AXE_VERSION ||= '~> 6.0'

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
      end

      #
      # Install the app from the Mac App Store
      #
      def action_install
        axe_gem.run_action(:install)
        new_resource.installed = true
      end

      private

      #
      # A resource for the AXElements gem dep
      #
      # @return [Chef::Resource::ChefGem]
      #
      def axe_gem
        unless @axe_gem
          @axe_gem = Resource::ChefGem.new('AXElements', run_context)
          @axe_gem.version(AXE_VERSION)
        end
        @axe_gem
      end
    end
  end
end
