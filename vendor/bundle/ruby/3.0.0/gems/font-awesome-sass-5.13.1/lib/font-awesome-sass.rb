module FontAwesome
  module Sass
    class << self
      def load!
        if rails?
          register_rails_engine
        elsif sprockets?
          register_sprockets
        elsif compass?
          register_compass_extension
        elsif deprecated_sass?
          ::Sass.load_paths << stylesheets_path
        end
      end

      # Paths
      def gem_path
        @gem_path ||= File.expand_path('..', File.dirname(__FILE__))
      end

      def stylesheets_path
        File.join(assets_path, 'stylesheets')
      end

      def fonts_path
        File.join(assets_path, 'fonts')
      end

      def assets_path
        @assets_path ||= File.join(gem_path, 'assets')
      end

      def sprockets?
        defined?(::Sprockets)
      end

      def compass?
        defined?(::Compass::Frameworks)
      end

      def rails?
        defined?(::Rails)
      end

      def deprecated_sass?
        # The deprecated `sass` gem:
        defined?(::Sass) && ::Sass.respond_to?(:load_paths)
      end

      private

      def register_compass_extension
        require 'font_awesome/sass/version'

        ::Compass::Frameworks.register(
          'font-awesome',
          version: FontAwesome::Sass::VERSION,
          path: gem_path,
          stylesheets_directory: stylesheets_path,
          templates_directory: File.join(gem_path, 'templates')
        )
      end

      def register_rails_engine
        require 'font_awesome/sass/rails/engine'
        require 'font_awesome/sass/rails/railtie'
      end

      def register_sprockets
        Sprockets.append_path(stylesheets_path)
        Sprockets.append_path(fonts_path)
      end
    end
  end
end

FontAwesome::Sass.load!
