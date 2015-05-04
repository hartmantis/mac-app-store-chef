# Encoding: UTF-8

require_relative '../../spec_helper'

class Chef
  class Provider
    # A fake macosx_accessibility provider
    #
    # @author Jonathan Hartman <j@p4nt5.com>
    class MacosxAccessibility < Provider::LWRPBase
    end
  end
end
