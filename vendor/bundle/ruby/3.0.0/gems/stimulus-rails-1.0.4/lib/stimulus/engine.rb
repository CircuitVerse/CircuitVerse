module Stimulus
  class Engine < ::Rails::Engine
    initializer "stimulus.assets" do
      if Rails.application.config.respond_to?(:assets)
        Rails.application.config.assets.precompile += %w( stimulus.js stimulus.min.js stimulus.min.js.map )
      end
    end
  end
end
