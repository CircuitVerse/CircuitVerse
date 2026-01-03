module Stimulus
  class Engine < ::Rails::Engine
    # If you don't want to precompile Stimulus's assets (e.g., you're using jsbundling),
    # you can do this in an initializer:
    #
    # config.after_initialize do
    #   config.assets.precompile -= Stimulus::Engine::PRECOMPILE_ASSETS
    # end
    PRECOMPILE_ASSETS = %w( stimulus.js stimulus.min.js stimulus.min.js.map ).freeze

    initializer "stimulus.assets" do
      if Rails.application.config.respond_to?(:assets)
        Rails.application.config.assets.precompile += PRECOMPILE_ASSETS
      end
    end
  end
end
