# frozen_string_literal: true

require "rails/generators"
require "fileutils"

module Serviceworker
  module Generators
    class InstallGenerator < ::Rails::Generators::Base
      desc "Make your Rails app a progressive web app"
      source_root File.join(File.dirname(__FILE__), "templates")

      def create_assets
        template "manifest.json", javascripts_dir("manifest.json.erb")
        template "serviceworker.js", javascripts_dir("serviceworker.js.erb")
        template "serviceworker-companion.js", javascripts_dir("serviceworker-companion.js")
      end

      def create_initializer
        template "serviceworker.rb", initializers_dir("serviceworker.rb")
      end

      def update_application_js
        ext, directive = detect_js_format
        snippet = "#{directive} require serviceworker-companion\n"
        append_to_file application_js_path(ext), snippet
      end

      def update_precompiled_assets
        snippet = "Rails.configuration.assets.precompile += %w[serviceworker.js manifest.json]\n"
        file_path = initializers_dir("assets.rb")
        FileUtils.touch file_path
        append_to_file file_path, snippet
      end

      def update_application_layout
        layout = detect_layout
        snippet = %(<link rel="manifest" href="/manifest.json" />)
        snippet += %(\n<meta name="apple-mobile-web-app-capable" content="yes">)
        unless layout
          conditional_warn "Could not locate application layout. To insert manifest tags manually, use:\n\n#{snippet}\n"
          return
        end
        insert_into_file layout, snippet, before: "</head>\n"
      end

      def add_offline_html
        template "offline.html", public_dir("offline.html")
      end

      private

      def application_js_path(ext)
        javascripts_dir("application#{ext}")
      end

      def detect_js_format
        %w[.js .js.erb .coffee .coffee.erb .js.coffee .js.coffee.erb].each do |ext|
          next unless File.exist?(javascripts_dir("application#{ext}"))
          return [ext, "#="] if ext.include?(".coffee")

          return [ext, "//="]
        end
      end

      def detect_layout
        layouts = %w[.html.erb .html.haml .html.slim .erb .haml .slim].map do |ext|
          layouts_dir("application#{ext}")
        end
        layouts.find { |layout| File.exist?(layout) }
      end

      def javascripts_dir(*paths)
        join("app", "assets", "javascripts", *paths)
      end

      def initializers_dir(*paths)
        join("config", "initializers", *paths)
      end

      def layouts_dir(*paths)
        join("app", "views", "layouts", *paths)
      end

      def public_dir(*paths)
        join("public", *paths)
      end

      def join(*paths)
        File.expand_path(File.join(*paths), destination_root)
      end

      def conditional_warn(warning)
        silenced? or warn warning
      end

      def silenced?
        ENV["RAILS_ENV"] == "test"
      end
    end
  end
end
