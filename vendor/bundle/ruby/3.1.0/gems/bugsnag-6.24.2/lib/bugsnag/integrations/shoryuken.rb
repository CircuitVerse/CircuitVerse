require 'shoryuken'

module Bugsnag
  ##
  # Extracts and attaches Shoryuken queue information to an error report
  class Shoryuken

    FRAMEWORK_ATTRIBUTES = {
      :framework => "Shoryuken"
    }

    def initialize
      Bugsnag.configure do |config|
        config.detected_app_type = "shoryuken"
        config.default_delivery_method = :synchronous
        config.runtime_versions["shoryuken"] = ::Shoryuken::VERSION
      end
    end

    def call(_, queue, _, body)
      begin
        Bugsnag.before_notify_callbacks << lambda {|report|
          report.add_tab(:shoryuken, {
            queue: queue,
            body: body
          })
        }

        yield
      rescue Exception => ex
        Bugsnag.notify(ex, true) do |report|
          report.severity = "error"
          report.severity_reason = {
            :type => Bugsnag::Report::UNHANDLED_EXCEPTION_MIDDLEWARE,
            :attributes => Bugsnag::Shoryuken::FRAMEWORK_ATTRIBUTES
          }
        end
        raise
      ensure
        Bugsnag.configuration.clear_request_data
      end
    end
  end
end

::Shoryuken.configure_server do |config|
  config.server_middleware do |chain|
    chain.add ::Bugsnag::Shoryuken
  end
end
