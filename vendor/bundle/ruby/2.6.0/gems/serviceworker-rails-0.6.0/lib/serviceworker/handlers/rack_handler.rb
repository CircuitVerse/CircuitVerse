# frozen_string_literal: true

module ServiceWorker
  module Handlers
    class RackHandler
      def initialize(root = Dir.getwd)
        @root = root
      end

      def call(env)
        path_info = env.fetch("serviceworker.asset_name")

        file_server.call(env.merge("PATH_INFO" => path_info))
      end

      def file_path(path_info)
        @root.join(path_info)
      end

      def file_server
        @file_server ||= ::Rack::File.new(@root)
      end
    end
  end
end
