# frozen_string_literal: true

Sentry.register_patch(:excon) do
  if defined?(::Excon)
    require "sentry/excon/middleware"
    if Excon.defaults[:middlewares]
      Excon.defaults[:middlewares] << Sentry::Excon::Middleware unless Excon.defaults[:middlewares].include?(Sentry::Excon::Middleware)
    end
  end
end
