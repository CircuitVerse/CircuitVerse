require_relative "boot"

# --- PROPSHAFT MIGRATION CHANGE ---
require "active_record/railtie"
require "active_storage/engine"
require "action_controller/railtie"
require "action_view/railtie"
require "action_mailer/railtie"
require "active_job/railtie"
require "action_cable/engine"
require "action_mailbox/engine"
require "action_text/engine"
require "rails/test_unit/railtie"

# Require the gems listed in Gemfile
Bundler.require(*Rails.groups)

# --- CRITICAL FIX: NEUTRALIZE SPROCKETS (SAFER METHOD) ---
# The 'commontator' gem loads Sprockets, which conflicts with Propshaft.
# We use class_eval to silence the 'build_manifest' method safely.
if defined?(Sprockets::Railtie)
  Sprockets::Railtie.class_eval do
    def self.build_manifest(app)
      # Return nothing. This prevents the TypeError crash.
      nil
    end
  end
end
# ---------------------------------------------------------

module Logix
  class Application < Rails::Application
    config.load_defaults 8.0
    config.autoload_lib(ignore: %w[assets tasks])

    config.action_mailer.preview_paths << "#{Rails.root}/lib/mailer_previews"
    config.view_component.preview_paths = "#{Rails.root}/spec/components/previews"
    config.view_component.default_preview_layout = "lookbook_preview"

    config.i18n.load_path += Dir[Rails.root.join("config", "locales", "**", "*.{rb,yml}")]
    config.i18n.available_locales = [:ar, :bn, :de, :en, :es, :fr, :hi, :ja, :ml, :mr, :ne]
    config.i18n.default_locale = :en
    config.i18n.fallbacks = true

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
