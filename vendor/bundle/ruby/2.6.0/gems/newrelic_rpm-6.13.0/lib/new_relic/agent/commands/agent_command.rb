# encoding: utf-8
# This file is distributed under New Relic's license terms.
# See https://github.com/newrelic/newrelic-ruby-agent/blob/main/LICENSE for complete details.

module NewRelic
  module Agent
    module Commands
      class AgentCommand
        attr_reader :id, :name, :arguments

        def initialize(raw_collector_command)
          @id        = raw_collector_command[0]
          @name      = raw_collector_command[1]["name"]
          @arguments = raw_collector_command[1]["arguments"]
        end
      end
    end
  end
end
