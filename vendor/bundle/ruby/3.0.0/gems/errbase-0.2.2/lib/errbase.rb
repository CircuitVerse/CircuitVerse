require "errbase/version"

module Errbase
  class << self
    def report(e, info = {})
      Airbrake.notify(e, info) if defined?(Airbrake)

      if defined?(Appsignal)
        if Appsignal::VERSION.to_i >= 3
          Appsignal.send_error(e) do |transaction|
            transaction.set_tags(info)
          end
        else
          Appsignal.send_error(e, info)
        end
      end

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

      if defined?(ScoutApm::Error)
        ScoutApm::Context.add(info)
        ScoutApm::Error.capture(e)
      end

      Sentry.capture_exception(e, extra: info) if defined?(Sentry)
    rescue => e
      $stderr.puts "[errbase] Error reporting exception: #{e.class.name}: #{e.message}"
    end
  end
end
