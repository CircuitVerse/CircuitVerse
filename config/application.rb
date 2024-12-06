require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Logix
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 6.0

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # configuring mailer previews directory
    config.action_mailer.preview_path << "#{Rails.root}/lib/mailer_previews"

    # config/application.rb
    config.view_component.preview_paths << "#{Rails.root}/spec/components/previews"
    config.i18n.raise_on_missing_translations = !Rails.env.production?
    config.i18n.load_path += Dir[Rails.root.join('config', 'locales', '**', '*.{rb,yml}')]
    config.i18n.available_locales = [:en, :hi, :bn, :mr, :ne]
    config.i18n.default_locale = :en
    config.i18n.fallbacks = true
    config.active_record.sqlite3_adapter_strict_strings_by_default = false
    config.active_record.encryption.hash_digest_class = OpenSSL::Digest::SHA1
    config.active_record.encryption.hash_digest_class = OpenSSL::Digest::SHA1


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
