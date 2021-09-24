require "errbase/version"

module Errbase
  class << self
    def report(e, info = {})
      Airbrake.notify(e, info) if defined?(Airbrake)

      Appsignal.send_error(e, info) if defined?(Appsignal)

      if defined?(Bugsnag)
        Bugsnag.notify(e) do |report|
          report.add_tab(:info, info) if info.any?
        end
      end

      ExceptionNotifier.notify_exception(e, data: info) if defined?(ExceptionNotifier)

      # TODO add info
      Google::Cloud::ErrorReporting.report(e) if defined?(Google::Cloud::ErrorReporting)

      Honeybadger.notify(e, context: info) if defined?(Honeybadger)

      NewRelic::Agent.notice_error(e, custom_params: info) if defined?(NewRelic::Agent)

      Raven.capture_exception(e, extra: info) if defined?(Raven)

      Raygun.track_exception(e, custom_data: info) if defined?(Raygun)

      Rollbar.error(e, info) if defined?(Rollbar)

      Sentry.capture_exception(e, extra: info) if defined?(Sentry)
    rescue => e
      $stderr.puts "[errbase] Error reporting exception: #{e.class.name}: #{e.message}"
    end
  end
end
