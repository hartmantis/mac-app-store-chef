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
    class Mas < Resource
      include Chef::Mixin::ShellOut

      provides :mac_app_store_mas, platform_family: 'mac_os_x'

      default_action :install

      #
      # Mas can be installed either from Homebrew or a direct binary download.
      #
      property :install_method,
               Symbol,
               equal_to: %i(direct homebrew),
               default: :direct

      property :version, [String, nil], default: nil

      #
      # Shell out to figure out if Mas is installed already and, if so, what
      # version it is.
      #
      load_current_value do
        res = shell_out('mas version || echo 0').stdout.strip
        version(res == '0' ? nil : res)
      end

      #
      # If Mas is not installed, install either the user-specified version of
      # it or the most recent one.
      #
      action :install do
        if current_resource.version.nil? && new_resource.version.nil?
          new_resource.version(latest_version)
        end

        converge_if_changed do
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
        new_resource.version(latest_version) unless new_resource.version
        converge_if_changed do
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
      # Check the GitHub API and fetch the latest released version of Mas.
      #
      # @return [String] the most recent version of the Mas CLI
      #
      def latest_version
        @latest_version ||= JSON.parse(
          Net::HTTP.get(
            URI('https://api.github.com/repos/argon/mas/releases')
          )
        ).first['tag_name'].gsub(/^v/, '')
      end
    end
  end
end
