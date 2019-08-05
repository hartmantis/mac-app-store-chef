# frozen_string_literal: true

#
# Cookbook:: mac-app-store
# Library:: resource/mac_app_store_mas
#
# Copyright:: 2015-2019, Jonathan Hartman
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
require_relative '../helpers/mas'

class Chef
  class Resource
    #
    # A Chef resource for managing installation of the Mas CLI tool for the
    # Mac App Store.
    #
    class MacAppStoreMas < Resource
      include Chef::Mixin::ShellOut

      provides :mac_app_store_mas, platform_family: 'mac_os_x'

      #
      # Optionally specify a version of Mas to install.
      #
      property :version, String

      #
      # The Apple ID user to sign in as, or false for none. The
      # converge_if_changed method does not detect a state change if a property
      # is being changed to nil, so we must use false here instead to support
      # "signed out" as a desired state.
      #
      property :username, [String, FalseClass]

      #
      # The password for the Apple ID user.
      #
      property :password, String, sensitive: true, desired_state: false

      default_action %i[install sign_in]

      load_current_value do
        username(MacAppStore::Helpers::Mas.signed_in_as? || false)
      end

      #
      # Install the Mas Homebrew package.
      #
      action :install do
        homebrew_package 'mas' do
          version new_resource.version unless new_resource.version.nil?
        end
      end

      #
      # Upgrade the Mas Homebrew package.
      #
      action :upgrade do
        homebrew_package 'mas' do
          version new_resource.version unless new_resource.version.nil?
          action :upgrade
        end
      end

      #
      # Uninstall the Mas Homebrew package.
      #
      action :remove do
        homebrew_package('mas') { action :remove }
      end

      #
      # Log in via Mas with an Apple ID and password.
      #
      action :sign_in do
        current_resource || raise(
          Chef::Exceptions::ValidationFailed,
          'Mas must be installed before you can sign in'
        )
        new_resource.username && new_resource.password || raise(
          Chef::Exceptions::ValidationFailed,
          'A username and password are required to sign into Mas'
        )

        converge_if_changed :username do
          action_sign_out if current_resource && current_resource.username

          cmd = "mas signin '#{new_resource.username}' '#{new_resource.password}'"
          execute "Sign in to Mas as #{new_resource.username}" do
            command cmd
            sensitive true
          end
        end
      end

      #
      # Log out of Mas.
      #
      action :sign_out do
        current_resource || raise(
          Chef::Exceptions::ValidationFailed,
          'Mas must be installed before you can sign out'
        )
        return unless current_resource.username

        execute 'Sign out of Mas' do
          command 'mas signout'
        end
      end

      #
      # Upgrade all installed apps.
      #
      action :upgrade_apps do
        current_resource || raise(
          Chef::Exceptions::ValidationFailed,
          'Mas must be installed before you can upgrade apps'
        )
        return unless MacAppStore::Helpers::Mas.upgradable_apps?

        execute 'Upgrade all installed apps' do
          command 'mas upgrade'
        end
      end
    end
  end
end
