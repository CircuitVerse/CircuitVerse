require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Logix
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 8.0

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w[assets tasks])

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")
   config.action_mailer.preview_paths << "#{Rails.root}/lib/mailer_previews"

        # config/application.rb
        config.view_component.preview_paths = "#{Rails.root}/spec/components/previews"
        config.view_component.default_preview_layout = "lookbook_preview"

        config.i18n.load_path += Dir[Rails.root.join("config", "locales", "**", "*.{rb,yml}")]
        config.i18n.available_locales = [:ar, :bn, :de, :en, :es, :fr, :hi, :ja, :ml, :mr, :ne]
        config.i18n.default_locale = :en
        config.i18n.fallbacks = true

        # configuring middleware
        config.middleware.use Rack::Attack
        # configuring middleware
           config.middleware.use Rack::Attack

           # configuring forum
           overrides = "#{Rails.root}/app/overrides"
           Rails.autoloaders.main.ignore(overrides)

           config.to_prepare do
             Dir.glob("#{overrides}/**/*_override.rb").each do |override|
               load override
             end
           end

           # Site config
           config.site_url = "https://circuitverse.org/"
           config.site_name = "CircuitVerse"
           config.site_category = "Digital Logic Circuits"
           config.site_download_url = "https://circuitverse.org/simulator"
           config.site_image = "https://circuitverse.org/img/circuitverse2.svg"
           config.site_description = "Explore Digital circuits online with CircuitVerse. With our easy to use simulator interface, you will be building circuits in no time."
           config.slack_url = "https://circuitverse.org/slack"
  end
end
