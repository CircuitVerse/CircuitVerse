# encoding: utf-8
# This file is distributed under New Relic's license terms.
# See https://github.com/newrelic/newrelic-ruby-agent/blob/main/LICENSE for complete details.

module NewRelic
  module Agent
    module Configuration
      module EventHarvestConfig

        extend self

        EVENT_HARVEST_CONFIG_KEY_MAPPING = {
          :analytic_event_data => :'analytics_events.max_samples_stored',
          :custom_event_data => :'custom_insights_events.max_samples_stored',
          :error_event_data => :'error_collector.max_event_samples_stored',
          :span_event_data => :'span_events.max_samples_stored'
        }

        def from_config(config)
          {:harvest_limits => EVENT_HARVEST_CONFIG_KEY_MAPPING.inject({}) do
            |connect_payload, (connect_payload_key, config_key)|
              connect_payload[connect_payload_key] = config[config_key]
              connect_payload
            end
          }
        end

        def to_config_hash(connect_reply)
          event_harvest_interval = connect_reply['event_harvest_config']['report_period_ms'] / 1000
          config_hash = EVENT_HARVEST_CONFIG_KEY_MAPPING.inject({}) do
            |event_harvest_config, (connect_payload_key, config_key)|
              if harvest_limit = connect_reply['event_harvest_config']['harvest_limits'][connect_payload_key.to_s]
                event_harvest_config[config_key] = harvest_limit
                report_period_key = :"event_report_period.#{connect_payload_key}"
                event_harvest_config[report_period_key] = event_harvest_interval
              end
              event_harvest_config
            end
          config_hash[:event_report_period] = event_harvest_interval
          config_hash
        end
      end
    end
  end
end
