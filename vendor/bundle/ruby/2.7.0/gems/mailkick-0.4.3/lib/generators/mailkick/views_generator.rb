require "rails/generators"

module Mailkick
  module Generators
    class ViewsGenerator < Rails::Generators::Base
      source_root File.expand_path("../../../../app/views", __FILE__)

      def copy_initializer_file
        directory "mailkick", "app/views/mailkick"
      end
    end
  end
end
