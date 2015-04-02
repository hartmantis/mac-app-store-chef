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
    #
    # Perform the installation of an App Store app
    #
    # @param [String] app_name
    # @param [Fixnum] timeout
    #
    # @raise [MacAppStoreCookbook::Exceptions::Timeout]
    #
    def self.install!(app_name, timeout)
      fail_unless_purchased(app_name)
      return nil if installed?(app_name)
      press(app_page_button(app_name))
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
    # @raise [MacAppStoreCookbook::Exceptions::Timeout]
    #
    #
    def self.wait_for_install(app_name, timeout)
      # Button might be 'Installed' or 'Open' depending on OS X version
      unless wait_for(:button,
                      app_page(app_name),
                      description: /^(Installed,|Open,)/,
                      timeout: timeout)
        fail(Exceptions::Timeout, "'#{app_name}' installation")
      end
    end

    #
    # Check whether an app is currently installed or not based on the presence
    # of an 'OPEN' button (rather than 'DOWNLOAD' or 'INSTALL') in the
    # 'Purchases' list
    #
    # @param [String] app_name
    #
    # @return [TrueClass, FalseClass]
    #
    def self.installed?(app_name)
      app_page_button(app_name).description.match(/^Open,/) ? true : false
    end

    #
    # Find the latest version of a package available, via the "Information"
    # sidebar in the app's store page
    #
    # @param [String] app_name
    #
    # @return [String]
    #
    def self.latest_version(app_name)
      app_page(app_name).main_window.static_text(value: 'Version: ').parent
        .static_text(value: /^[0-9]/).value
    end

    #
    # Find and return the button (Open, Install, etc.) in the app page
    #
    # @param [String] app_name
    #
    # @return [AX::Button]
    #
    def self.app_page_button(app_name)
      app_page(app_name).main_window.web_area.group.group.button
    end

    #
    # If not already at it, follow the app link in the Purchases list to
    # navigate to the app's main page, and return the Application instance
    # whose state was just altered
    #
    # @param [String] app_name
    #
    # @return [AX::Application]
    #
    # @raise [MacAppStoreCookbook::Exceptions::AppNotPurchased]
    # @raise [MacAppStoreCookbook::Exceptions::Timeout]
    #
    def self.app_page(app_name)
      unless app_store.main_window.web_area.description == app_name
        press(row(app_name).link)
        unless wait_for(:button,
                        app_store.main_window.web_area,
                        description: /^(Install,|Download,|Installed,|Open,)/)
          fail(Exceptions::Timeout, "'#{app_name}' app page")
        end
      end
      app_store
    end

    #
    # Check whether an app is purchased and raise an exception if not
    #
    # @raise [MacAppStoreCookbook::Exceptions::AppNotPurchased]
    #
    def self.fail_unless_purchased(app_name)
      purchased?(app_name) || fail(Exceptions::AppNotPurchased, app_name)
    end

    #
    # Check whether an app is purchased or not
    #
    # @param [String] app_name
    #
    # @return [TrueClass, FalseClass]
    #
    def self.purchased?(app_name)
      if app_store.main_window.web_area.description == app_name
        r = /^(Open,|Install,|Installed,|Download,)/
        app_page_button(app_name).description.match(r) ? true : false
      else
        !row(app_name).nil?
      end
    end

    #
    # Find the row for the app in question in the App Store window
    #
    # @param [String] app_name
    #
    # @return [AX::Row, NilClass]
    #
    def self.row(app_name)
      purchases.main_window.search(:row, link: { title: app_name })
    end

    #
    # If not already at it, navigate to the 'Purchases' page and return the
    # Application object whose state may have just been altered.
    #
    # @return [AX::Application]
    #
    # @raise [MacAppStoreCookbook::Exceptions::Timeout]
    # @raise [MacAppStoreCookbook::Exceptions::UserNotSignedIn]
    #
    def self.purchases
      signed_in? || fail(Exceptions::UserNotSignedIn)
      unless app_store.main_window.web_area.description == 'Purchases'
        select_menu_item(app_store, 'Store', 'Purchases')
      end
      unless wait_for(:table, app_store.main_window, description: 'Purchases')
        fail(Exceptions::Timeout, 'Purchases list')
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
      fail(Exceptions::AppleIDInfoMissing, 'username') if username.nil?
      fail(Exceptions::AppleIDInfoMissing, 'password') if password.nil?
      sign_out! if signed_in?
      sign_in_menu
      set(username_field, username)
      set(password_field, password)
      press(sign_in_button)
      wait_for_sign_in
    end

    #
    # Wait for the 'Store' -> 'Sign Out' menu to load (for after signing in)
    #
    # @raise [MacAppStoreCookbook::Exceptions::Timeout]
    #
    def self.wait_for_sign_in
      unless wait_for(:menu_item,
                      app_store.menu_bar_item(title: 'Store'),
                      title: 'Sign Out')
        fail(Exceptions::Timeout, 'sign in')
      end
    end

    #
    # Find and return the 'Sign In' button from the popup menu.
    # This requires that the sign in menu has already been selected.
    #
    # @return [AX::Button]
    #
    def self.sign_in_button
      sign_in_menu.main_window.sheet.button(title: 'Sign In')
    end

    #
    # Find and return the 'Apple ID' text field from the sign in popup.
    # This requires that the sign in menu has already been selected.
    #
    # @return[AX::TextField]
    #
    def self.username_field
      sign_in_menu.main_window.sheet.text_field(
        title_ui_element: sign_in_menu.main_window.sheet.static_text(
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
      sign_in_menu.main_window.sheet.secure_text_field(
        title_ui_element: sign_in_menu.main_window.sheet.static_text(
          value: 'Password'
        )
      )
    end

    #
    # If not already displaying the 'Sign In' popup menu, select 'Store' ->
    # 'Sign In...' from the menu bar and return the application instance.
    #
    # @return [AX::Application]
    #
    # @raise [MacAppStoreCookbook::Exceptions::Timeout]
    #
    def self.sign_in_menu
      unless app_store.main_window.search(:button, title: 'Sign In')
        select_menu_item(app_store, 'Store', 'Sign In…')
        unless wait_for(:button,
                        app_store.main_window,
                        title: 'Sign In')
          fail(Exceptions::Timeout, 'Sign In window')
        end
      end
      app_store
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
    #
    # @raise [MacAppStoreCookbook::Exceptions::Timeout]
    #
    def self.app_store
      require 'ax_elements'
      as = AX::Application.new('com.apple.appstore')
      # The page and navigation buttons load separately, not in a consistent
      # order
      unless wait_for(:web_area, as.main_window)
        fail(Exceptions::Timeout, 'App Store')
      end
      unless wait_for(:radio_button, as.main_window.toolbar, id: 'purchased')
        fail(Exceptions::Timeout, 'App Store toolbar nav buttons')
      end
      as
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

    #
    # Override AXE's wait_for method with one that calls it with a set of
    # common parameters
    #
    # @param [Symbol] element
    # @param [AX::Application, AX::StandardWindow, AX::MenuBarItem] ancestor
    # @param [Hash] search_params
    #
    def self.wait_for(element, ancestor, search_params = {})
      require 'ax_elements'
      AX.wait_for(element,
                  { ancestor: ancestor, timeout: 30 }.merge(search_params))
    end
  end

  class Exceptions
    # A custom exception class for App Store task timeouts
    #
    # @author Jonathan Hartman <j@p4nt5.com>
    class Timeout < StandardError
      def initialize(task)
        super("Timed out waiting for #{task} to load")
      end
    end

    # A custom exception class for cases where one attempts to perform
    # operations on an app that hasn't been purchased
    #
    # @author Jonathan Hartman <j@p4nt5.com>
    class AppNotPurchased < StandardError
      def initialize(name)
        super("App '#{name}' is not in the Purchases list")
      end
    end

    # A custom exception class for where one attempts an action that can't
    # be completed due to the user not being signed in
    #
    # @author Jonathan Hartman <j@p4nt5.com>
    class UserNotSignedIn < StandardError
      def initialize
        super('User must be signed in to perform this action')
      end
    end

    # A custom exception class for missing Apple ID information
    #
    # @author Jonathan Hartman <j@p4nt5.com>
    class AppleIDInfoMissing < StandardError
      def initialize(param)
        super("An Apple ID '#{param}' *must* be provided or a user already " <<
              'signed into the App Store')
      end
    end
  end
end
