require 'mailman'

module Bugsnag
  ##
  # Extracts and appends mailman message information to error reports
  class Mailman

    FRAMEWORK_ATTRIBUTES = {
      :framework => "Mailman"
    }

    def initialize
      Bugsnag.configuration.internal_middleware.use(Bugsnag::Middleware::Mailman)
      Bugsnag.configuration.detected_app_type = "mailman"
      Bugsnag.configuration.runtime_versions["mailman"] = ::Mailman::VERSION
    end

    ##
    # Calls the mailman middleware.
    def call(mail)
      begin
        Bugsnag.configuration.set_request_data :mailman_msg, mail.to_s
        yield
      rescue Exception => ex
        Bugsnag.notify(ex, true) do |report|
          report.severity = "error"
          report.severity_reason = {
            :type => Bugsnag::Report::UNHANDLED_EXCEPTION_MIDDLEWARE,
            :attributes => FRAMEWORK_ATTRIBUTES
          }
        end
        raise
      ensure
        Bugsnag.configuration.clear_request_data
      end
    end
  end
end


if Mailman.config.respond_to?(:middleware)
  Mailman.config.middleware.add ::Bugsnag::Mailman
end
