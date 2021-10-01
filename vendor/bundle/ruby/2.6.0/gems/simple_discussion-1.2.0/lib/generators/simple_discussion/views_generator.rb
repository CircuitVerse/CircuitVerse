require 'rails/generators'

module SimpleDiscussion
  module Generators
    class ViewsGenerator < Rails::Generators::Base
      source_root File.expand_path("../../../..", __FILE__)

      def copy_views
        directory 'app/views', 'app/views'
      end
    end
  end
end
