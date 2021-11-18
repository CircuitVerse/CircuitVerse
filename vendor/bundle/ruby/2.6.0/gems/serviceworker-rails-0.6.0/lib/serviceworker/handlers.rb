# frozen_string_literal: true

require "serviceworker/handlers/rack_handler"

module ServiceWorker
  module Handlers
    extend self

    def build(handler)
      resolve_handler(handler) || default_handler
    end

    def handler_for_route_match(route_match)
      options = route_match.options
      return webpacker_handler if Route.webpacker?(options)
      return sprockets_handler if Route.sprockets?(options)

      nil
    end

    def ===(other)
      other.respond_to?(:call)
    end

    def handler_for_name(name)
      available_handlers = %w[sprockets webpacker rack]
      if available_handlers.include?(name.to_s)
        send("#{name}_handler")
      else
        raise ServiceWorker::Error,
              "Unknown handler #{name.inspect}. Please use one of #{available_handlers.inspect}"
      end
    end

    def resolve_handler(handler)
      case handler
      when Handlers
        handler
      when Symbol, String
        handler_for_name(handler)
      end
    end

    def webpacker_handler
      require "serviceworker/handlers/webpacker_handler"
      ServiceWorker::Handlers::WebpackerHandler.new
    end

    def sprockets_handler
      require "serviceworker/handlers/sprockets_handler"
      ServiceWorker::Handlers::SprocketsHandler.new
    end

    def rack_handler
      ServiceWorker::Handlers::RackHandler.new
    end

    def default_handler
      if sprockets?
        sprockets_handler
      else
        rack_handler
      end
    end

    def webpacker?
      defined?(::Webpacker)
    end

    def sprockets?
      defined?(::Rails) && ::Rails.configuration.assets
    end
  end
end
