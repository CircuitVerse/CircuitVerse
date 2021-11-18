# encoding: utf-8
# This file is distributed under New Relic's license terms.
# See https://github.com/newrelic/newrelic-ruby-agent/blob/main/LICENSE for complete details.

DependencyDetection.defer do
  named :excon

  # We have two ways of instrumenting Excon:
  # - For newer versions, use the middleware mechanism Excon exposes
  # - For older versions, monkey-patch Excon::Connection#request
  #
  # EXCON_MIN_VERSION is the minimum version we attempt to instrument at all.
  # EXCON_MIDDLEWARE_MIN_VERSION is the min version we use the newer
  #   instrumentation for.
  #
  # Note that middlewares were added to Excon prior to 0.19, but we don't
  # use middleware-based instrumentation prior to that version because it didn't
  # expose a way for middlewares to know about request failures.
  #
  # Why don't we use Excon.defaults[:instrumentor]?
  # While this might seem a perfect fit, it unfortunately isn't suitable in
  # current form. Someone might reasonably set the default instrumentor to
  # something else after we install our instrumentation. Ideally, excon would
  # itself conform to the #subscribe interface of ActiveSupport::Notifications,
  # so we could safely subscribe and not be clobbered by future subscribers,
  # but alas, it does not yet.

  EXCON_MIN_VERSION = Gem::Version.new("0.10.1")
  EXCON_MIDDLEWARE_MIN_VERSION = Gem::Version.new("0.19.0")

  depends_on do
    defined?(::Excon) && defined?(::Excon::VERSION)
  end

  executes do
    excon_version = Gem::Version.new(::Excon::VERSION)
    if excon_version >= EXCON_MIN_VERSION
      install_excon_instrumentation(excon_version)
    else
      ::NewRelic::Agent.logger.warn("Excon instrumentation requires at least version #{EXCON_MIN_VERSION}")
    end
  end

  def install_excon_instrumentation(excon_version)
    require 'new_relic/agent/distributed_tracing/cross_app_tracing'
    require 'new_relic/agent/http_clients/excon_wrappers'

    if excon_version >= EXCON_MIDDLEWARE_MIN_VERSION
      install_middleware_excon_instrumentation
    else
      install_legacy_excon_instrumentation
    end
  end

  def install_middleware_excon_instrumentation
    ::NewRelic::Agent.logger.info 'Installing middleware-based Excon instrumentation'
    require 'new_relic/agent/instrumentation/excon/middleware'
    defaults = Excon.defaults

    if defaults[:middlewares]
      defaults[:middlewares] << ::Excon::Middleware::NewRelicCrossAppTracing
    else
      ::NewRelic::Agent.logger.warn("Did not find :middlewares key in Excon.defaults, skipping Excon instrumentation")
    end
  end

  def install_legacy_excon_instrumentation
    ::NewRelic::Agent.logger.info 'Installing legacy Excon instrumentation'
    require 'new_relic/agent/instrumentation/excon/connection'
    ::Excon::Connection.install_newrelic_instrumentation
  end
end
