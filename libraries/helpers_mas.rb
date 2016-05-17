# Encoding: UTF-8
#
# Cookbook Name:: mac-app-store
# Library:: helpers_mas
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
        # Return the user currently signed in.
        #
        # @return [String, NilClass] the current user or nil
        #
        def signed_in_as?
          return nil unless installed?
          acct = shell_out('mas account').stdout.strip
          acct == 'Not signed in' ? nil : acct
        end

        #
        # Return the current install method.
        #
        # @return [Symbol, NilClass] :direct, :homebrew, or nil
        #
        def installed_by?
          return nil unless installed?
          brew = shell_out('brew list argon/mas/mas || true').stdout.strip
          brew.empty? ? :direct : :homebrew
        end

        #
        # Return the currently installed version of Mas or nil if it's not
        # installed.
        #
        # @return [String, NilClass] the version of Mas installed
        #
        def installed_version?
          res = shell_out('mas version || true').stdout.strip
          res.empty? ? nil : res
        end

        #
        # Check whether Mas is currently installed.
        #
        # @return [TrueClass, FalseClass] whether Mas is installed
        #
        def installed?
          res = shell_out('mas version || true').stdout.strip
          res.empty? ? false : true
        end

        #
        # Check the GitHub API and fetch the latest released version of Mas.
        #
        # @return [String] the most recent version of the Mas CLI
        #
        def latest_version?
          @latest_version ||= JSON.parse(
            Net::HTTP.get(
              URI('https://api.github.com/repos/argon/mas/releases')
            )
          ).first['tag_name'].gsub(/^v/, '')
        end
      end
    end
  end
end
