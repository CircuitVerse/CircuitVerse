module Lookbook
  module ApplicationHelper
    def lookbook_asset_path(file, version: true)
      path = "#{Engine.host_config.relative_url_root}/lookbook-assets/#{file}".gsub("//", "/")
      version ? "#{path}?v=#{Lookbook::VERSION}" : path
    end

    def lookbook_landing_path
      landing = Engine.pages.find(&:landing?) || Engine.pages.first
      if landing.present?
        lookbook_page_path landing.lookup_path
      else
        lookbook_home_path
      end
    end

    # Requests

    def request_frame
      request.headers["X-Lookbook-Frame"] || "root"
    end

    def frame_request?
      request.headers["X-Lookbook-Frame"].present?
    end
  end
end
