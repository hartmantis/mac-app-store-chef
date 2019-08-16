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

require 'chef/resource'
require_relative '../helpers/mas'

class Chef
  class Resource
    #
    # A Chef resource for managing installation of the Mas CLI tool for the
    # Mac App Store.
    #
    class MacAppStoreMas < Resource
      provides :mac_app_store_mas, platform_family: 'mac_os_x'

      #
      # The resource name is never used.
      #
      property :name, String, default: 'default'

      #
      # Optionally specify a version of Mas to install.
      #
      property :version, String

      default_action :install

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
      # Upgrade all installed apps.
      #
      action :upgrade_apps do
        return if shell_out!('mas outdated').stdout.strip.empty?

        execute 'Upgrade all installed apps' do
          command 'mas upgrade'
        end
      end
    end
  end
end
