# Encoding: UTF-8

require_relative '../../spec_helper'

class Chef
  class Resource
    # A fake macosx_accessibility resource
    #
    # @author Jonathan Hartman <j@p4nt5.com>
    class MacosxAccessibility < Resource::LWRPBase
      self.resource_name = :macosx_accessibility
      actions :insert, :enable
      default_action :insert
      attribute :items, kind_of: Array
    end
  end
end
