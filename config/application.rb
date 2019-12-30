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
    config.action_mailer.preview_path = "#{Rails.root}/lib/mailer_previews"
    config.middleware.insert_after ActionDispatch::Static, Rack::Deflater

    # Site config
    config.site_url = "https://circuitverse.org/"
    config.site_name = "CircuitVerse"
    config.site_category = "Digital Logic Circuits"
    config.site_download_url = "https://circuitverse.org/simulator"
    config.site_image = "https://circuitverse.org/img/circuitverse2.svg"
    config.site_description = "Explore Digital circuits online with CircuitVerse. With our easy to use simulator interface, you will be building circuits in no time."
    config.slack_url = "https://join.slack.com/t/circuitverse-team/shared_invite/enQtNjc4MzcyNDE5OTA3LTdjYTM5NjFiZWZlZGI2MmU1MmYzYzczNmZlZDg5MjYxYmQ4ODRjMjQxM2UyMWI5ODUzODQzMDU2ZDEzNjI4NmE"
  end
end
