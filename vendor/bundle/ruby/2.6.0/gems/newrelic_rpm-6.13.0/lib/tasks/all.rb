# encoding: utf-8
# This file is distributed under New Relic's license terms.
# See https://github.com/newrelic/newrelic-ruby-agent/blob/main/LICENSE for complete details.

# This is required to load in task definitions from merb
Dir.glob(File.join(File.dirname(__FILE__),'*.rake')) do |file|
  load file
end
