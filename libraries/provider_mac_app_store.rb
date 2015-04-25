# Encoding: UTF-8
#
# Cookbook Name:: mac-app-store
# Library:: provider_mac_app_store
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
require 'chef/resource/chef_gem'
require_relative 'helpers'
require_relative 'resource_mac_app_store'

class Chef
  class Provider
    # A Chef provider for Mac App program itself
    #
    # @author Jonathan Hartman <j@p4nt5.com>
    class MacAppStore < Provider::LWRPBase
      include MacAppStoreCookbook::Helpers

      AXE_VERSION ||= '~> 7.0.0.pre'

      use_inline_resources

      #
      # WhyRun is supported by this provider
      #
      # @return [TrueClass, FalseClass]
      #
      def whyrun_supported?
        true
      end

      attr_reader :original_focus

      def initialize(new_resource, run_context)
        super
        install_axe_gem
        trust_app
        require 'ax_elements'
        @original_focus = AX::SystemWide.new.focused_application
      end

      #
      # Load and return the current resource
      #
      # @return [Chef::Resource::MacAppStore]
      #
      def load_current_resource
        @current_resource ||= Resource::MacAppStore.new(new_resource.name)
        @current_resource.running(app_store_running?)
        @current_resource
      end

      #
      # Open the App Store program and sign in as the specified user
      #
      action :open do
        if !app_store_running?
          new_resource.updated_by_last_action(true)
          set_focus_to(app_store)
        else
          set_focus_to(app_store)
        end
        if new_resource.username && new_resource.password
          sign_in!(new_resource.username, new_resource.password)
        elsif new_resource.username || new_resource.password
          fail(Chef::Exceptions::ValidationFailed,
               'Username and password must be provided together')
        elsif !signed_in?
          fail(Chef::Exceptions::ValidationFailed,
               'Someone must be signed into the App Store or a username and ' \
               'password provided')
        end
        new_resource.running(true)
      end

      #
      # Quit the App Store program if it's running and return focus to the
      # original target
      #
      action :quit do
        if app_store_running?
          quit!
          new_resource.updated_by_last_action(true)
        end
        set_focus_to(original_focus)
        new_resource.running(false)
      end

      private

      #
      # Enable accessibility for running application
      #
      def trust_app
        mac_app_store_trusted_app current_application_name do
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
