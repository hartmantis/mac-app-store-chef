# Encoding: UTF-8
#
# Cookbook Name:: mac-app-store
# Library:: resource_mac_app_store_app
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

require 'chef/resource'
require_relative 'provider_mac_app_store_app'

class Chef
  class Resource
    # A Chef resource for Mac App Store applications
    #
    # @author Jonathan Hartman <j@p4nt5.com>
    class MacAppStoreApp < Resource
      attr_accessor :installed
      alias_method :installed?, :installed

      def initialize(name, run_context = nil)
        super
        @resource_name = :mac_app_store_app
        @provider = Provider::MacAppStoreApp
        @action = :install
        @allowed_actions = [:install]

        @installed = false
      end

      #
      # Require a pkgutil-style app ID to use for install status checks
      #
      # @param [String, NilClass] arg
      # @return [String]
      #
      def app_id(arg = nil)
        set_or_return(:app_id, arg, kind_of: [String], required: true)
      end

      #
      # Timeout value for app download + install
      #
      # @param [Fixnum, NilClass] arg
      # @return [Fixnum]
      #
      def timeout(arg = nil)
        set_or_return(:timeout, arg, kind_of: [Fixnum], default: 600)
      end
    end
  end
end
