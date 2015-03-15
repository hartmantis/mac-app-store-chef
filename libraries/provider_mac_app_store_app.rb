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
require 'chef/resource/chef_gem'
require_relative 'helpers'
require_relative 'resource_mac_app_store_app'

class Chef
  class Provider
    # A Chef provider for Mac App Store apps
    #
    # @author Jonathan Hartman <j@p4nt5.com>
    class MacAppStoreApp < Provider::LWRPBase
      include Chef::Mixin::ShellOut
      use_inline_resources

      AXE_VERSION ||= '~> 6.0'

      #
      # WhyRun is supported by this provider
      #
      # @return [TrueClass, FalseClass]
      #
      def whyrun_supported?
        true
      end

      attr_reader :original_focus
      attr_reader :quit_when_done
      alias_method :quit_when_done?, :quit_when_done

      def initialize(new_resource, run_context)
        super
        install_axe_gem
        trust_app
        require 'ax_elements'
        @original_focus = AX::SystemWide.new.focused_application
        @quit_when_done = !MacAppStoreCookbook::Helpers.running?
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
        unless MacAppStoreCookbook::Helpers.installed?(new_resource.name)
          set_focus_to(MacAppStoreCookbook::Helpers.app_store)
          MacAppStoreCookbook::Helpers.sign_in!(new_resource.username,
                                                new_resource.password)
          MacAppStoreCookbook::Helpers.install!(new_resource.name,
                                                new_resource.timeout)
          @new_resource.updated_by_last_action(true)
          quit_when_done? && MacAppStoreCookbook::Helpers.quit!
          set_focus_to(original_focus)
        end
        new_resource.installed(true)
      end

      private

      #
      # Use pkgutil to determine whether an app is installed
      #
      # @return [TrueClass, FalseClass]
      #
      def installed?
        !shell_out("pkgutil --pkg-info #{new_resource.app_id}").error?
      end

      #
      # Enable accessibility for running application
      #
      def trust_app
        mac_app_store_trusted_app '/usr/libexec/sshd-keygen-wrapper' do
          compile_time true
          action :create
        end
      end

      #
      # Install the AXElements gem
      #
      def install_axe_gem
        chef_gem 'AXElements' do
          compile_time(true) if respond_to?(:compile_time)
          version AXE_VERSION
          action :install
        end
      end
    end
  end
end
