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
require 'chef/dsl/include_recipe'
require 'chef/resource/chef_gem'
require_relative 'helpers'
require_relative 'resource_mac_app_store'

class Chef
  class Provider
    # A Chef provider for Mac App program itself
    #
    # @author Jonathan Hartman <j@p4nt5.com>
    class MacAppStore < Provider::LWRPBase
      include Chef::DSL::IncludeRecipe
      include MacAppStoreCookbook::Helpers

      AXE_VERSION ||= '~> 7.0'

      use_inline_resources

      attr_reader :original_focus

      #
      # WhyRun is supported by this provider
      #
      # @return [TrueClass, FalseClass]
      #
      def whyrun_supported?
        true
      end

      #
      # Load and return the current resource. Note that this does not require
      # Accessibility API access to complete.
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
        prep
        require 'ax_elements'
        @original_focus = AX::SystemWide.new.focused_application
        open_app_store
        sign_in!(new_resource.username, new_resource.password)
        new_resource.running(true)
      end

      #
      # Quit the App Store program if it's running and return focus to the
      # original target
      #
      action :quit do
        prep
        require 'ax_elements'
        quit_app_store
        set_focus_to(original_focus) unless original_focus.nil?
        new_resource.running(false)
      end

      private

      #
      # Quit the App Store if it's running.
      #
      def quit_app_store
        doit = app_store_running?
        quit! if doit
        new_resource.updated_by_last_action(true) if doit
      end

      #
      # Start the App Store, an action which will also assign focus to it.
      #
      def open_app_store
        already_open = app_store_running?
        app_store
        new_resource.updated_by_last_action(true) unless already_open
      end

      #
      # Perform the system prep work of installing the AXElements gem and
      # giving the app running Chef accessibility rights.
      #
      def prep
        install_xcode_tools
        install_axe_gem
        trust_app
      end

      #
      # Enable accessibility for running application and converge the resource
      # immediately so everything else in this provider doesn't have to go in
      # ruby_block resources.
      #
      def trust_app
        include_recipe_now 'privacy_services_manager'
        app = current_application_name
        psm = privacy_services_manager "Grant Accessibility rights to #{app}" do
          service 'accessibility'
          applications [app]
          admin true
        end
        psm.run_action(:add)
      end

      #
      # Install the AXElements gem. Converge the resource immediately so
      # everything else in this provider doesn't have to go in ruby_block
      # resources.
      #
      def install_axe_gem
        chef_gem 'AXElements' do
          compile_time(false) if respond_to?(:compile_time)
          version AXE_VERSION
        end.run_action(:install)
      end

      #
      # Install the Xcode command line tools via the resource provided in the
      # build-essentials cookbook. Converge the resource immediately so
      # everything else in this provider doesn't have to go in a ruby_block
      # resource.
      #
      def install_xcode_tools
        xcode_command_line_tools('default').run_action(:install)
      end
    end
  end
end
