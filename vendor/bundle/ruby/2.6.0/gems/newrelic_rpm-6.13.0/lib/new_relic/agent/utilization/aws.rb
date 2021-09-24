# encoding: utf-8
# This file is distributed under New Relic's license terms.
# See https://github.com/newrelic/newrelic-ruby-agent/blob/main/LICENSE for complete details.

require 'new_relic/agent/utilization/vendor'

module NewRelic
  module Agent
    module Utilization
      class AWS < Vendor
        vendor_name "aws"
        endpoint "http://169.254.169.254/2016-09-02/dynamic/instance-identity/document"
        keys ["instanceId", "instanceType", "availabilityZone"]
        key_transforms :to_sym
      end
    end
  end
end
