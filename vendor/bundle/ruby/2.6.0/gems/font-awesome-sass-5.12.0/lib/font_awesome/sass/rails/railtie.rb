require 'font_awesome/sass/rails/helpers'

module FontAwesome
  module Sass
    module Rails
      class Railtie < ::Rails::Railtie
        initializer 'font-awesome-sass.view_helpers' do
          ActiveSupport.on_load(:action_view) do
            include ViewHelpers
          end
        end
      end
    end
  end
end
