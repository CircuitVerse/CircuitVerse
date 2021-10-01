# Configure Rails 3.1
module Remotipart
  module Rails

    class Engine < ::Rails::Engine
      initializer "remotipart.view_helper" do
        ActiveSupport.on_load :action_view do
          include RequestHelper
          include ViewHelper
        end
      end

      initializer "remotipart.controller_helper" do
        ActiveSupport.on_load :action_controller do
          include RequestHelper
          include RenderOverrides
        end
      end

      initializer "remotipart.include_middelware" do
        if ::Rails.version >= '5'
          # Rails 5 no longer instantiates ActionDispatch::ParamsParser
          # https://github.com/rails/rails/commit/a1ced8b52ce60d0634e65aa36cb89f015f9f543d
          config.app_middleware.use Middleware
        else
          config.app_middleware.insert_after ActionDispatch::ParamsParser, Middleware
        end
      end
    end

  end
end
