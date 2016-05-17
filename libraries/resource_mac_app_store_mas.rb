# Encoding: UTF-8
#
# Cookbook Name:: mac-app-store
# Library:: resource_mac_app_store_mas
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

require 'net/http'
require 'chef/resource'
require 'chef/mixin/shell_out'

class Chef
  class Resource
    # A Chef resource for managing installation of the Mas CLI tool for the
    # Mac App Store.
    #
    # @author Jonathan Hartman <j@p4nt5.com>
    class MacAppStoreMas < Resource
      include Chef::Mixin::ShellOut

      provides :mac_app_store_mas, platform_family: 'mac_os_x'

      property :install_method,
               Symbol,
               equal_to: %i(direct homebrew),
               default: :direct
      property :username, [String, nil]
      property :password, String, desired_state: false
      property :installed, [TrueClass, FalseClass]
      property :version, String

      default_action %i(install sign_in)

      load_current_value do
        installed(installed?)
        if installed
          version(installed_version?)
          username(signed_in_as?)
          install_method(installed_by?)
        end
      end

      #
      # If Mas is not installed, install either the user-specified version of
      # it or the most recent one.
      #
      action :install do
        new_resource.installed(true)
        new_resource.version(latest_version?) if new_resource.version.nil?

        converge_if_changed :installed do
          case new_resource.install_method
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
            homebrew_package 'argon/mas/mas'
          end
        end
      end

      #
      # Upgrade Mas if there's a more recent version than is currently
      # installed.
      #
      action :upgrade do
        new_resource.version(latest_version?) unless new_resource.version

        converge_if_changed :version do
          case new_resource.install_method
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
            homebrew_package 'argon/mas/mas' do
              action :upgrade
            end
          end
        end
      end

      #
      # Uninstall Mas by either deleting the file or removing the Homebrew
      # package.
      #
      action :remove do
        case new_resource.install_method
        when :direct
          file('/usr/local/bin/mas') { action :delete }
        when :homebrew
          include_recipe 'homebrew'
          homebrew_package('argon/mas/mas') { action :remove }
        end
      end

      #
      # Log in via Mas with an Apple ID and password.
      #
      action :sign_in do
        converge_if_changed :username do
          execute "Sign in to Mas as #{new_resource.username}" do
            command "mas signin #{new_resource.username}" \
                    " #{new_resource.password}"
          end
        end
      end

      #
      # Log out of Mas.
      #
      action :sign_out do
        new_resource.username(nil)

        converge_if_changed :username do
          execute 'Sign out of Mas' do
            command 'mas signout'
          end
        end
      end

      #
      # Return the user currently signed in.
      #
      # @return [String, NilClass] the current user or nil
      #
      def signed_in_as?
        acct = shell_out('mas account').stdout.strip
        acct == 'Not signed in' ? nil : acct
      end

      #
      # Return the current install method.
      #
      # @return [Symbol, NilClass] :direct, :homebrew, or nil
      #
      def installed_by?
        return nil unless installed?
        brew = shell_out('brew list argon/mas/mas || true').stdout.strip
        brew.empty? ? :direct : :homebrew
      end

      #
      # Return the currently installed version of Mas or nil if it's not
      # installed.
      #
      # @return [String, NilClass] the version of Mas installed
      #
      def installed_version?
        res = shell_out('mas version || true').stdout.strip
        res.empty? ? nil : res
      end

      #
      # Check whether Mas is currently installed.
      #
      # @return [TrueClass, FalseClass] whether Mas is installed
      #
      def installed?
        res = shell_out('mas version || true').stdout.strip
        res.empty? ? false : true
      end

      #
      # Check the GitHub API and fetch the latest released version of Mas.
      #
      # @return [String] the most recent version of the Mas CLI
      #
      def latest_version?
        @latest_version ||= JSON.parse(
          Net::HTTP.get(
            URI('https://api.github.com/repos/argon/mas/releases')
          )
        ).first['tag_name'].gsub(/^v/, '')
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
