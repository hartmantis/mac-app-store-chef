# Encoding: UTF-8
#
# Cookbook Name:: mac-app-store
# Library:: provider_mac_app_store_app
#
# Copyright 2014 Jonathan Hartman
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

require 'chef/provider'
require 'chef/mixin/shell_out'
require 'chef/resource/chef_gem'
require_relative 'resource_mac_app_store_app'

class Chef
  class Provider
    # A Chef provider for Mac App Store apps
    #
    # @author Jonathan Hartman <j@p4nt5.com>
    class MacAppStoreApp < Provider
      include Chef::Mixin::ShellOut

      AXE_VERSION ||= '~> 6.0'

      attr_reader :original_focus
      attr_reader :quit_when_done
      alias_method :quit_when_done?, :quit_when_done

      def initialize(new_resource, run_context)
        super
        axe_gem.run_action(:install)
        require 'ax_elements'
        @original_focus = AX::SystemWide.new.focused_application
        @quit_when_done = NSRunningApplication
                          .runningApplicationsWithBundleIdentifier(
                            'com.apple.appstore'
                          ).empty?
      end

      #
      # WhyRun is supported by this provider
      #
      # @return [TrueClass, FalseClass]
      #
      def whyrun_supported?
        true
      end

      #
      # Load and return the current resource
      #
      # @return [Chef::Resource::MacAppStoreApp]
      #
      def load_current_resource
        @current_resource ||= Resource::MacAppStoreApp.new(new_resource.name)
        @current_resource.installed = installed?
        @current_resource
      end

      #
      # Install the app from the Mac App Store
      #
      def action_install
        unless current_resource.installed?
          set_focus_to(app_store)
          press(install_button)
          # TODO: Icky hardcoded sleep is icky
          sleep 5

          quit_when_done? && app_store.terminate
          set_focus_to(original_focus)
        end
        new_resource.installed = true
      end

      private

      #
      # Find the latest version of a package available, via the "Information"
      # sidebar in the app's store page
      #
      # @return [String]
      #
      def latest_version
        app_page.main_window.static_text(value: 'Version: ').parent
          .static_text(value: /^[0-9]/).value
      end

      #
      # Use pkgutil to determine whether an app is installed
      #
      # @return [TrueClass, FalseClass]
      #
      def installed?
        !shell_out("pkgutil --pkg-info #{new_resource.app_id}").error?
      end

      #
      # Find the install button in the app row
      #
      # @return [AX::Button]
      #
      def install_button
        app_page.main_window.web_area.group.group.button
      end

      #
      # Follow the app link in the Purchases list to navigate to the app's
      # main page, and return the Application instance whose state was just
      # altered
      #
      # @return [AX::Application]
      #
      def app_page
        press(row.link)
        # TODO: Icky hardcoded sleep is icky
        sleep 3
        app_store
      end

      #
      # Check whether an app is purchased or not
      #
      # @return [TrueClass, FalseClass]
      #
      def purchased?
        row
        true
      rescue Accessibility::SearchFailure
        false
      end

      #
      # Find the row for the app in question in the App Store window
      #
      # @return [AX::Row]
      #
      def row
        purchases.main_window.row(link: { title: new_resource.name })
      end

      #
      # Set focus to the App Store, navigate to the Purchases list, and return
      # the Application object whose state was just altered
      #
      # @return [AX::Application]
      #
      def purchases
        unless wait_for(:menu_item, ancestor: app_store, title: 'Purchases')
          fail(Chef::Exceptions::CommandTimeout,
               'Timed out waiting for App Store to load')
        end
        select_menu_item(app_store, 'Store', 'Purchases')
        # TODO: Icky hardcoded sleep is icky
        sleep 5
        begin
          app_store.main_window.link(title: 'sign in')
          fail(Chef::Exceptions::ConfigurationError,
               'User must be signed into App Store to install apps')
        rescue Accessibility::SearchFailure
          app_store
        end
      end

      #
      # Find the App Store application running or launch it
      #
      # @return [AX::Application]
      #
      def app_store
        @app_store ||= AX::Application.new('com.apple.appstore')
      end

      #
      # A resource for the AXElements gem dep
      #
      # @return [Chef::Resource::ChefGem]
      #
      def axe_gem
        unless @axe_gem
          @axe_gem = Resource::ChefGem.new('AXElements', run_context)
          @axe_gem.version(AXE_VERSION)
        end
        @axe_gem
      end
    end
  end
end
