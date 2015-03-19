# Encoding: UTF-8
#
# Cookbook Name:: mac-app-store
# Library:: provider_mac_app_store_trusted_app
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
require_relative 'resource_mac_app_store_trusted_app'

class Chef
  class Provider
    # A Chef provider for modifying OS X's Accessibility settings to trust
    # an app with control
    #
    # @author Jonathan Hartman <j@p4nt5.com>
    class MacAppStoreTrustedApp < Provider::LWRPBase
      include Chef::Mixin::ShellOut
      use_inline_resources

      SQLITE3_VERSION ||= '~> 1.3'
      DB_PATH ||= '/Library/Application Support/com.apple.TCC/TCC.db'

      #
      # WhyRun is supported by this provider
      #
      # @return [TrueClass, FalseClass]
      #
      def whyrun_supported?
        true
      end

      #
      # Create a new instance and, before allowing anything else to happen,
      # install the sqlite3 gem
      #
      # @return [Chef::Provider::MacAppStoreTrustedApp]
      #
      def initialize(new_resource, run_context)
        super
        install_sqlite3_gem
        require 'sqlite3'
      end

      #
      # Load and return the current resource
      #
      # @return [Chef::Resource::MacAppStoreTrustedApp]
      #
      def load_current_resource
        @current_resource ||= Resource::MacAppStoreTrustedApp
                              .new(new_resource.name)
        @current_resource.created(created?)
        @current_resource
      end

      #
      # Ensure the app is trusted
      #
      action :create do
        unless created?
          @new_resource.updated_by_last_action(true)
          update! || insert!
        end
        new_resource.created(true)
      end

      private

      #
      # Run an INSERT query against the SQLite DB to enable access
      #
      def insert!
        return nil unless row.nil?
        db.execute('INSERT INTO access VALUES(?, ?, ?, ?, ?, ?)',
                   'kTCCServiceAccessibility',
                   new_resource.name,
                   new_resource.name.start_with?('/') ? 1 : 0,
                   1,
                   0,
                   nil)
      end

      #
      # Run an UPDATE query against the SQLite DB to enable access
      #
      def update!
        return nil if row.nil?
        db.execute(
          'UPDATE access SET allowed = 1 WHERE service = ? AND client = ?',
          'kTCCServiceAccessibility',
          new_resource.name
        )
      end

      #
      # Determine whether an app is already trusted or not
      #
      # @return [TrueClass, FalseClass]
      #
      def created?
        r = row
        !r.nil? && r['allowed'] == 1
      end

      #
      # Fetch and return the DB row for the app
      #
      #
      def row
        res = db.execute(
          'SELECT * FROM access WHERE service = ? AND client = ?',
          'kTCCServiceAccessibility',
          new_resource.name)
        res.empty? ? nil : res[0]
      end

      #
      # Open and return a connection to the SQLite DB that holds the
      # Accessibility settings
      #
      # @return [SQLite3::Database]
      #
      def db
        SQLite3::Database.new(::File.expand_path(DB_PATH),
                              results_as_hash: true)
      end

      #
      # Install the sqlite3 gem
      #
      def install_sqlite3_gem
        chef_gem 'sqlite3' do
          compile_time(true) if defined?(compile_time)
          version SQLITE3_VERSION
          action :install
        end
      end
    end
  end
end
