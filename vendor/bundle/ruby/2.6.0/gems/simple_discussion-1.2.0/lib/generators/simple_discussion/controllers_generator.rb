require 'rails/generators'

module SimpleDiscussion
  module Generators
    class ControllersGenerator < Rails::Generators::Base
      source_root File.expand_path("../../../..", __FILE__)

      def copy_controllers
        directory 'app/controllers/simple_discussion', 'app/controllers/simple_discussion'
      end
    end
  end
end
