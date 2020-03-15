# frozen_string_literal: true

require "rack/file"

module ServiceWorker
  module Handlers
    class SprocketsHandler
      def call(env)
        path_info = env.fetch("serviceworker.asset_name")

        if config.compile
          sprockets_server.call(env.merge("PATH_INFO" => path_info))
        else
          file_server.call(env.merge("PATH_INFO" => asset_path(path_info)))
        end
      end

      private

      def sprockets_server
        ::Rails.application.assets
      end

      def file_server
        @file_server ||= ::Rack::File.new(::Rails.public_path)
      end

      def config
        ::Rails.configuration.assets
      end

      def asset_path(path)
        if controller_helpers.respond_to?(:compute_asset_path)
          controller_helpers.compute_asset_path(path)
        else
          logical_asset_path(path)
        end
      end

      def controller_helpers
        ::ActionController::Base.helpers
      end

      def logical_asset_path(path)
        asset_path = controller_helpers.asset_path(path)
        uri = URI.parse(asset_path)
        uri.host = nil
        uri.scheme = nil
        uri.to_s
      rescue URI::InvalidURIError
        asset_path
      end
    end
  end
end
