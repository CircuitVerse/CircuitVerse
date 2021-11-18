# encoding: utf-8
# This file is distributed under New Relic's license terms.
# See https://github.com/newrelic/newrelic-ruby-agent/blob/main/LICENSE for complete details.
#
# If you are looking to instrument rake tasks in a Rails environment, but the
# task doesn't depend on :environment, this task may be included to ensure that
# the agent will load.

NewRelic::Agent.manual_start(:sync_startup => false)
