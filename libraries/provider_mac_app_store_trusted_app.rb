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

require 'chef/log'
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
          update! || insert!
          new_resource.updated_by_last_action(true)
        end
        new_resource.created(true)
      end

      private

      #
      # Run an INSERT query against the SQLite DB to enable access
      #
      def insert!
        return nil unless row.nil?
        db_query('INSERT INTO access VALUES(' \
                 '"kTCCServiceAccessibility", ' \
                 "\"#{new_resource.name}\", " \
                 "#{new_resource.name.start_with?('/') ? 1 : 0}, " \
                 '1, 0, NULL)')
      end

      #
      # Run an UPDATE query against the SQLite DB to enable access
      #
      def update!
        return nil if row.nil? || created?
        db_query('UPDATE access SET allowed = 1 WHERE ' \
                 'service = "kTCCServiceAccessibility" AND ' \
                 "client = \"#{new_resource.name}\"")
      end

      #
      # Determine whether an app is already trusted or not
      #
      # @return [TrueClass, FalseClass]
      #
      def created?
        r = row
        !r.nil? && r[3].to_i == 1
      end

      #
      # Fetch and return the DB row for the app as an array where the schema
      # is:
      #
      # | service | client | client_type | allowed | prompt_count | cs_req |
      # | kTCC... | <NAME> | 0/1         | 0/1     | 0/1          | NULL   |
      # |
      #
      def row
        res = db_query('SELECT * FROM access WHERE ' \
                       'service = "kTCCServiceAccessibility" AND ' \
                       "client = \"#{new_resource.name}\" LIMIT 1")
        res.empty? ? nil : res
      end

      #
      # Open and return a connection to the SQLite DB that holds the
      # Accessibility settings
      #
      # @param [String] query
      #
      # @return [Array]
      #
      # @raise [Mixlib::ShellOut::ShellCommandFailed]
      #
      def db_query(query)
        path = ::File.expand_path(DB_PATH)
        unless ::File.exist?(path)
          Chef::Log.info('Accessibility settings DB not present; resetting...')
          reset_accessibility_settings
        end
        Chef::Log.debug("Querying Accessibility DB with '#{query}'")
        shell_out!("sqlite3 #{path.gsub(' ', '\ ')} '#{query}'").stdout
          .split('|')
      end

      #
      # Use the `tccutil` command to reset the Accessibility settings database.
      # For use in cases where a new OS X instance is brought up and doesn't
      # yet have an initialized Accessibility database.
      #
      def reset_accessibility_settings
        shell_out!('tccutil reset Accessibility')
      end
    end
  end
end
