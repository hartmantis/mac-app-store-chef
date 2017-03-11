# encoding: utf-8
# frozen_string_literal: true
#
# Cookbook Name:: mac-app-store
# Library:: resource_mac_app_store_mas
#
# Copyright 2015-2017, Jonathan Hartman
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
require_relative 'helpers_mas'

class Chef
  class Resource
    # A Chef resource for managing installation of the Mas CLI tool for the
    # Mac App Store.
    #
    # @author Jonathan Hartman <j@p4nt5.com>
    class MacAppStoreMas < Resource
      include Chef::Mixin::ShellOut

      provides :mac_app_store_mas, platform_family: 'mac_os_x'

      #
      # The method of installation for Mas, either :direct (GitHub) or :homebrew
      #
      property :source,
               Symbol,
               coerce: proc { |v| v.to_sym },
               equal_to: %i(direct homebrew),
               default: :direct

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
      property :password, String, desired_state: false

      #
      # The system user to execute Mas commands as,
      #
      property :system_user, String, default: Etc.getlogin, desired_state: false

      #
      # If circumstances require, the reattach-to-user-namespace utility can be
      # used every time we shell out to Mas.
      #
      property :use_rtun, [TrueClass, FalseClass], default: false

      ######################################################################
      # Every property below this point is for tracking resource state and #
      # should *not* be overridden.                                        #
      ######################################################################

      #
      # A property to track the installed state of Mas.
      #
      property :installed, [TrueClass, FalseClass]

      #
      # A property to track whether any app upgrades are available.
      #
      property :upgradable_apps, [TrueClass, FalseClass]

      default_action %i(install sign_in)

      load_current_value do |desired|
        MacAppStore::Helpers::Mas.user = desired.system_user
        installed(MacAppStore::Helpers::Mas.installed?)
        if installed
          version(MacAppStore::Helpers::Mas.installed_version?)
          username(MacAppStore::Helpers::Mas.signed_in_as? || false)
          source(MacAppStore::Helpers::Mas.installed_by?)
          upgradable_apps(MacAppStore::Helpers::Mas.upgradable_apps?)
        end
      end

      #
      # If Mas is not installed, install either the user-specified version of
      # it or the most recent one.
      #
      action :install do
        new_resource.installed(true)
        MacAppStore::Helpers::Mas.user = new_resource.system_user

        unless new_resource.version
          new_resource.version(MacAppStore::Helpers::Mas.latest_version?)
        end

        converge_if_changed :installed do
          case new_resource.source
          when :direct
            path = ::File.join(Chef::Config[:file_cache_path], 'mas-cli.zip')
            remote_file path do
              source 'https://github.com/argon/mas/releases/download/' \
                     "v#{new_resource.version}/mas-cli.zip"
            end
            execute 'Extract Mas-CLI zip file' do
              command "unzip -d /usr/local/bin/ -o #{path}"
            end
          when :homebrew
            include_recipe 'homebrew'
            homebrew_package 'mas'
          end
        end
      end

      #
      # Upgrade Mas if there's a more recent version than is currently
      # installed.
      #
      action :upgrade do
        new_resource.installed(true)
        MacAppStore::Helpers::Mas.user = new_resource.system_user

        unless new_resource.version
          new_resource.version(MacAppStore::Helpers::Mas.latest_version?)
        end

        converge_if_changed :version do
          case new_resource.source
          when :direct
            path = ::File.join(Chef::Config[:file_cache_path], 'mas-cli.zip')
            remote_file path do
              source 'https://github.com/argon/mas/releases/download/' \
                     "v#{new_resource.version}/mas-cli.zip"
            end
            execute 'Extract Mas-CLI zip file' do
              command "unzip -d /usr/local/bin/ -o #{path}"
            end
          when :homebrew
            include_recipe 'homebrew'
            homebrew_package('mas') { action :upgrade }
          end
        end
      end

      #
      # Uninstall Mas by either deleting the file or removing the Homebrew
      # package.
      #
      action :remove do
        new_resource.installed(false)

        converge_if_changed :installed do
          case new_resource.source
          when :direct
            file('/usr/local/bin/mas') { action :delete }
          when :homebrew
            include_recipe 'homebrew'
            homebrew_package('mas') { action :remove }
          end
        end
      end

      #
      # Log in via Mas with an Apple ID and password.
      #
      action :sign_in do
        new_resource.username && new_resource.password || raise(
          Chef::Exceptions::ValidationFailed,
          'A username and password are required to sign into Mas'
        )

        converge_if_changed :username do
          cmd = if new_resource.use_rtun
                  include_recipe 'reattach-to-user-namespace'
                  'reattach-to-user-namespace mas signin ' \
                    "'#{new_resource.username}' '#{new_resource.password}'"
                else
                  "mas signin '#{new_resource.username}' " \
                    "'#{new_resource.password}'"
                end
          execute "Sign in to Mas as #{new_resource.username}" do
            command cmd
            user new_resource.system_user
            returns [0, 6]
            sensitive true
          end
        end
      end

      #
      # Log out of Mas.
      #
      action :sign_out do
        new_resource.username(false)

        converge_if_changed :username do
          cmd = if new_resource.use_rtun
                  include_recipe 'reattach-to-user-namespace'
                  'reattach-to-user-namespace mas signout'
                else
                  'mas signout'
                end
          execute 'Sign out of Mas' do
            command cmd
            user new_resource.system_user
          end
        end
      end

      #
      # Upgrade all installed apps.
      #
      action :upgrade_apps do
        new_resource.upgradable_apps(false)

        converge_if_changed :upgradable_apps do
          cmd = if new_resource.use_rtun
                  include_recipe 'reattach-to-user-namespace'
                  'reattach-to-user-namespace mas upgrade'
                else
                  'mas upgrade'
                end
          execute 'Upgrade all installed apps' do
            command cmd
            user new_resource.system_user
          end
        end
      end

      #
      # Override resource's text rendering to remove password information.
      #
      # @return [String]
      #
      def to_text
        password.nil? ? super : super.gsub(password, '****************')
      end
    end
  end
end
