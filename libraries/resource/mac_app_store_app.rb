# frozen_string_literal: true

#
# Cookbook Name:: mac-app-store
# Library:: resource/mac_app_store_app
#
# Copyright 2015-2019, Jonathan Hartman
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

require 'etc'
require 'chef/resource'
require_relative '../helpers/app'

class Chef
  class Resource
    # A Chef resource for Mac App Store applications.
    #
    # @author Jonathan Hartman <j@p4nt5.com>
    class MacAppStoreApp < Resource
      include Chef::Mixin::ShellOut

      provides :mac_app_store_app, platform_family: 'mac_os_x'

      #
      # The name of the app to be installed (defaults to the resource name).
      #
      property :app_name, String, name_property: true

      default_action :install

      load_current_value do |desired|
        unless MacAppStore::Helpers::App.installed?(desired.app_name)
          current_value_does_not_exist!
        end
      end

      action :install do
        return if current_resource

        app_id = MacAppStore::Helpers::App.app_id_for?(new_resource.app_name)
        raise(Exceptions::InvalidAppName, new_resource.app_name) unless app_id

        execute "Install #{new_resource.app_name} with Mas" do
          command "mas install #{app_id}"
        end
      end

      action :upgrade do
        return if current_resource && \
                  !MacAppStore::Helpers::App.upgradable?(new_resource.app_name)

        app_id = MacAppStore::Helpers::App.app_id_for?(new_resource.app_name)
        raise(Exceptions::InvalidAppName, new_resource.app_name) unless app_id

        execute "Upgrade #{new_resource.app_name} with Mas" do
          command "mas install #{app_id}"
        end
      end

      class Exceptions
        # An exception class for app names that don't turn up in `mas search`.
        #
        # @author Jonathan Hartman <j@p4nt5.com>
        class InvalidAppName < StandardError
          def initialize(app_name)
            super("Could not find '#{app_name}' in the Mac App Store. " \
                  'Is the name correct and do you own the app?')
          end
        end
      end
    end
  end
end
