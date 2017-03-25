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
      property :password, String, sensitive: true, desired_state: false

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

      load_current_value do
        current_value_does_not_exist! unless MacAppStore::Helpers::Mas.installed?
        installed(true)
        version(MacAppStore::Helpers::Mas.installed_version?)
        username(MacAppStore::Helpers::Mas.signed_in_as? || false)
        source(MacAppStore::Helpers::Mas.installed_by?)
        upgradable_apps(MacAppStore::Helpers::Mas.upgradable_apps?)
      end

      #
      # If Mas is not installed, install either the user-specified version of
      # it or the most recent one.
      #
      action :install do
        return if current_resource

        case new_resource.source
        when :direct
          ver = new_resource.version || MacAppStore::Helpers::Mas.latest_version?
          path = ::File.join(Chef::Config[:file_cache_path], 'mas-cli.zip')
          remote_file path do
            source 'https://github.com/mas-cli/mas/releases/download/' \
                   "v#{ver}/mas-cli.zip"
          end
          execute 'Extract Mas-CLI zip file' do
            command "unzip -d /usr/local/bin/ -o #{path}"
          end
        when :homebrew
          include_recipe 'homebrew'
          homebrew_package 'mas'
        end
      end

      #
      # Upgrade Mas if there's a more recent version than is currently
      # installed.
      #
      action :upgrade do
        case new_resource.source
        when :direct
          ver = new_resource.version || MacAppStore::Helpers::Mas.latest_version?
          return if current_resource && current_resource.version == ver

          path = ::File.join(Chef::Config[:file_cache_path], 'mas-cli.zip')
          remote_file path do
            source 'https://github.com/mas-cli/mas/releases/download/' \
                   "v#{ver}/mas-cli.zip"
          end
          execute 'Extract Mas-CLI zip file' do
            command "unzip -d /usr/local/bin/ -o #{path}"
          end
        when :homebrew
          include_recipe 'homebrew'
          homebrew_package('mas') { action :upgrade }
        end
      end

      #
      # Uninstall Mas by either deleting the file or removing the Homebrew
      # package.
      #
      action :remove do
        return unless current_resource

        case new_resource.source
        when :direct
          file('/usr/local/bin/mas') { action :delete }
        when :homebrew
          include_recipe 'homebrew'
          homebrew_package('mas') { action :remove }
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
          action_sign_out if current_resource && current_resource.username

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
            sensitive true
          end
        end
      end

      #
      # Log out of Mas.
      #
      action :sign_out do
        return unless current_resource && current_resource.username

        cmd = if new_resource.use_rtun
                include_recipe 'reattach-to-user-namespace'
                'reattach-to-user-namespace mas signout'
              else
                'mas signout'
              end
        execute 'Sign out of Mas' do
          command cmd
        end
      end

      #
      # Upgrade all installed apps.
      #
      action :upgrade_apps do
        return unless current_resource && current_resource.upgradable_apps

        cmd = if new_resource.use_rtun
                include_recipe 'reattach-to-user-namespace'
                'reattach-to-user-namespace mas upgrade'
              else
                'mas upgrade'
              end
        execute 'Upgrade all installed apps' do
          command cmd
        end
      end
    end
  end
end
