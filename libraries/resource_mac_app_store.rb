# Encoding: UTF-8
#
# Cookbook Name:: mac-app-store
# Library:: resource_mac_app_store
#
# Copyright 2015-2016, Jonathan Hartman
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

require 'chef/resource/lwrp_base'

class Chef
  class Resource
    # A Chef resource for Mac App Store program itself
    #
    # @author Jonathan Hartman <j@p4nt5.com>
    class MacAppStore < Resource::LWRPBase
      self.resource_name = :mac_app_store
      actions :open, :quit
      default_action :open

      #
      # Attribute for the App Store's running state
      #
      attribute :running,
                kind_of: [NilClass, TrueClass, FalseClass],
                default: nil
      alias_method :running?, :running

      #
      # An optional Apple ID username
      #
      attribute :username, kind_of: [NilClass, String], default: nil

      #
      # An optional Apple ID password
      #
      attribute :password, kind_of: [NilClass, String], default: nil

      #
      # Override resource's text rendering to remove password information
      #
      # @return [String]
      #
      def to_text
        password.nil? ? super : super.gsub(password, '****************')
      end
    end
  end
end
