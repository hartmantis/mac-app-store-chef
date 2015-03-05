# Encoding: UTF-8
#
# Cookbook Name:: mac-app-store
# Library:: helpers
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

require 'chef/exceptions'

module MacAppStoreCookbook
  # A set of helper methods for interacting with the Mac App Store
  #
  # @author Jonathan Hartman <j@p4nt5.com>
  module Helpers
    def self.install!(app_name, timeout)
      return nil if installed?(app_name)
      press(install_button(app_name))
      wait_for_install(app_name, timeout)
    end

    #
    # Wait up to the resource's timeout attribute for the app to download and
    # install
    #
    # @param [String] app_name
    # @param [Fixnum] timeout
    #
    # @return [TrueClass]
    #
    # @raise [Chef::Exceptions::CommandTimeout]
    #
    #
    def self.wait_for_install(app_name, timeout)
      (0..timeout).each do
        # Button might be 'Installed' or 'Open' depending on OS X version
        term = /^(Installed,|Open,)/
        return true if app_page.main_window.search(:button, description: term)
        sleep 1
      end
      fail(Chef::Exceptions::CommandTimeout,
           "Timed out waiting for '#{app_name}' to install")
    end

    #
    # Find the latest version of a package available, via the "Information"
    # sidebar in the app's store page
    #
    # @param [String] app_name
    # @return [String]
    #
    def self.latest_version(app_name)
      app_page(app_name).main_window.static_text(value: 'Version: ').parent
        .static_text(value: /^[0-9]/).value
    end

    #
    # Find the install button in the app row
    #
    # @param [String] app_name
    # @return [AX::Button]
    #
    def self.install_button(app_name)
      app_page(app_name).main_window.web_area.group.group.button
    end

    #
    # Follow the app link in the Purchases list to navigate to the app's
    # main page, and return the Application instance whose state was just
    # altered
    #
    # @param [String] app_name
    # @return [AX::Application]
    #
    def self.app_page(app_name)
      purchased?(app_name) || fail(Chef::Exceptions::Application,
                                   "App '#{app_name}' has not been purchased")
      press(row.link)
      # TODO: Icky hardcoded sleep is icky
      sleep 3
      app_store
    end

    #
    # Check whether an app is purchased or not
    #
    # @param [String] app_name
    # @return [TrueClass, FalseClass]
    #
    def self.purchased?(app_name)
      !row(app_name).nil?
    end

    #
    # Find the row for the app in question in the App Store window
    #
    # @param [String] app_name
    # @return [AX::Row, NilClass]
    #
    def self.row(app_name)
      purchases.main_window.search(:row, link: { title: app_name })
    end

    #
    # Set focus to the App Store, navigate to the Purchases list, and return
    # the Application object whose state was just altered
    #
    # @return [AX::Application]
    # @raise [Chef::Exceptions::CommandTimeout]
    # @raise [Chef::Exceptions::ConfigurationError]
    #
    def self.purchases
      unless signed_in?
        fail(Chef::Exceptions::ConfigurationError,
             'User must be signed into App Store to install apps')
      end
      select_menu_item(app_store, 'Store', 'Purchases')
      unless wait_for(:group, ancestor: app_store, id: 'purchased')
        fail(Chef::Exceptions::CommandTimeout,
             'Timed out waiting for Purchases page to load')
      end
      app_store
    end

    #
    # Sign out of the App Store if a user is currently signed in
    #
    def self.sign_out!
      return unless signed_in?
      select_menu_item(app_store, 'Store', 'Sign Out')
    end

    #
    # Go to the Sign In menu and sign in as a user.
    # Will return immediately if any user is signed in, whether or not it's
    # the same user as provided to this function.
    #
    # @param [String] username
    # @param [String] password
    #
    def self.sign_in!(username, password)
      return if signed_in? && current_user? == username
      sign_out! if current_user? != username
      select_menu_item(app_store, 'Store', 'Sign In…')
      sleep 1
      set(username_field, username)
      set(password_field, password)
      press(sign_in_button)
      sleep 5
    end

    #
    # Find and return the 'Sign In' button from the popup menu.
    # This requires that the sign in menu has already been selected.
    #
    # @return [AX::Button]
    #
    def self.sign_in_button
      app_store.main_window.sheet.button(title: 'Sign In')
    end

    #
    # Find and return the 'Apple ID' text field from the sign in popup.
    # This requires that the sign in menu has already been selected.
    #
    # @return[AX::TextField]
    #
    def self.username_field
      app_store.main_window.sheet.text_field(
        title_ui_element: app_store.main_window.sheet.static_text(
          value: 'Apple ID '
        )
      )
    end

    #
    # Find and return the 'Password' text field from the sign in popup.
    # This requires that the sign in menu has already been selected.
    #
    # @return [AX::SecureTextField]
    #
    def self.password_field
      app_store.main_window.sheet.secure_text_field(
        title_ui_element: app_store.main_window.sheet.static_text(
          value: 'Password'
        )
      )
    end

    #
    # Find and return the user currently signed in, or nil if nobody is signed
    # in
    #
    # @return [NilClass, String]
    #
    def self.current_user?
      return nil unless signed_in?
      app_store.menu_bar_item(title: 'Store')
        .menu_item(title: /^View My Account /)
        .title[/^View My Account \((.*)\)/, 1]
    end

    #
    # Check whether a user is currently signed into the App Store or not
    #
    # @return [TrueClass, FalseClass]
    #
    def self.signed_in?
      !app_store.menu_bar_item(title: 'Store').search(:menu_item,
                                                      title: 'Sign Out').nil?
    end

    #
    # Quit the App Store app
    #
    def self.quit!
      app_store.terminate if running?
    end

    #
    # Find the App Store application running or launch it
    #
    # @return [AX::Application]
    # @raise [Chef::Exceptions::CommandTimeout]
    #
    def self.app_store
      require 'ax_elements'
      app_store = AX::Application.new('com.apple.appstore')
      unless wait_for(:menu_item, ancestor: app_store, title: 'Purchases')
        fail(Chef::Exceptions::CommandTimeout,
             'Timed out waiting for the App Store to load')
      end
      app_store
    end

    #
    # Return whether the App Store app is running or not
    #
    # @return [TrueClass, FalseClass]
    #
    def self.running?
      require 'ax_elements'
      !NSRunningApplication.runningApplicationsWithBundleIdentifier(
        'com.apple.appstore'
      ).empty?
    end
  end
end
