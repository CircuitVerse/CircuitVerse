# frozen_string_literal: true

module Sentry
  module Rails
    class RescuedExceptionInterceptor
      def initialize(app)
        @app = app
      end

      def call(env)
        return @app.call(env) unless Sentry.initialized?

        begin
          @app.call(env)
        rescue => e
          env["sentry.rescued_exception"] = e if report_rescued_exceptions?
          raise e
        end
      end

      def report_rescued_exceptions?
        # In rare edge cases, `Sentry.configuration` might be `nil` here.
        # Hence, we use a safe navigation and fallback to a reasonable default
        # of `true` in case the configuration couldn't be loaded.
        # See https://github.com/getsentry/sentry-ruby/issues/2386
        report_rescued_exceptions = Sentry.configuration&.rails&.report_rescued_exceptions
        return report_rescued_exceptions unless report_rescued_exceptions.nil?

        # `true` is the default for `report_rescued_exceptions`, as specified in
        # `sentry-rails/lib/sentry/rails/configuration.rb`.
        true
      end
    end
  end
end
