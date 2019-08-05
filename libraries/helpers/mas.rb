# frozen_string_literal: true

#
# Cookbook:: mac-app-store
# Library:: helpers/mas
#
# Copyright:: 2015-2019, Jonathan Hartman
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

require 'json'
require 'net/http'
require 'chef/mixin/shell_out'

module MacAppStore
  module Helpers
    # A set of helper methods for interacting with the Mas app.
    #
    # @author Jonathan Hartman <j@p4nt5.com>
    class Mas
      class << self
        include Chef::Mixin::ShellOut

        #
        # Check whether any installed apps are outdated.
        #
        # @return [TrueClass, FalseClass] any available upgrades
        #
        def upgradable_apps?
          outdated = shell_out('mas outdated').stdout.strip
          outdated.empty? ? false : true
        end

        #
        # Return the user currently signed in.
        #
        # @return [String, NilClass] the current user or nil
        #
        def signed_in_as?
          acct = shell_out('mas account').stdout.strip
          acct == 'Not signed in' ? nil : acct
        end
      end
    end
  end
end
