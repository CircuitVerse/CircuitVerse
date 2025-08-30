require "active_support/core_ext/integer/time"

Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # Code is not reloaded between requests.
  config.enable_reloading = false

  # Eager load code on boot for better performance and memory savings (ignored by Rake tasks).
  config.eager_load = true

  # Full error reports are disabled.
  config.consider_all_requests_local = false

  # Turn on fragment caching in view templates.
  config.action_controller.perform_caching = true

  # Custom error pages (preserved from Rails 7)
  config.exceptions_app = routes

  # Cache assets for far-future expiry since they are all digest stamped.
  config.public_file_server.headers = { "cache-control" => "public, max-age=#{1.year.to_i}" }

  # Enable serving of images, stylesheets, and JavaScripts from an asset server.
  # config.asset_host = "http://assets.example.com"

  # Store uploaded files (use Amazon S3 in production)
  if ENV["AWS_S3_BUCKET_NAME"].present?
    config.active_storage.service = :amazon_custom
  else
    config.active_storage.service = :amazon
  end

  # Assume all access to the app is happening through a SSL-terminating reverse proxy.
  config.assume_ssl = true

  # Force all access to the app over SSL, use Strict-Transport-Security, and use secure cookies.
  # Uncomment this if you want to enforce SSL (recommended for production)
  # config.force_ssl = true

  # Skip http-to-https redirect for the default health check endpoint.
  # config.ssl_options = { redirect: { exclude: ->(request) { request.path == "/up" } } }

  # Disable serving static files from `/public` by default since Apache or NGINX already handles this
  config.public_file_server.enabled = ENV["RAILS_SERVE_STATIC_FILES"].present?

  # Asset compression (adjust based on whether you use Sprockets or Propshaft)
  # For Sprockets (if still using):
  if defined?(Sprockets)
    config.assets.js_compressor = :terser
    config.assets.css_compressor = nil
    config.assets.compile = false
  end

  # Log configuration
  config.log_tags = [:request_id]
  config.log_level = :debug  # Keep debug level as per original config

  # If logging to STDOUT
  if ENV["RAILS_LOG_TO_STDOUT"].present?
    config.logger = ActiveSupport::TaggedLogging.logger(STDOUT)
  end

  # Change to "info" in production for less verbose logging
  # config.log_level = ENV.fetch("RAILS_LOG_LEVEL", "info")

  # Prevent health checks from clogging up the logs (Rails 8 feature)
  config.silence_healthcheck_path = "/up"

  # Don't log any deprecations.
  config.active_support.report_deprecations = false

  # Redis cache store (preserved from Rails 7)
  config.cache_store = :redis_cache_store

  # Sidekiq for background jobs (preserved from Rails 7)
  config.active_job.queue_adapter = :sidekiq

  # Ignore bad email addresses and do not raise email delivery errors.
  # config.action_mailer.raise_delivery_errors = false
  config.action_mailer.perform_caching = false

  # Mailer settings (preserved from Rails 7)
  config.action_mailer.delivery_method = :ses
  config.action_mailer.default_url_options = { host: "https://circuitverse.org/" }
  config.action_mailer.asset_host = "https://circuitverse.org"

  # Web Push (VAPID) configuration (preserved from Rails 7)
  config.vapid_public_key = ENV["VAPID_PUBLIC_KEY"] || ""
  config.vapid_private_key = ENV["VAPID_PRIVATE_KEY"] || ""

  # CSRF origin check (preserved from Rails 7)
  config.action_controller.forgery_protection_origin_check = false

  # Paperclip configuration (if still using - consider migrating to Active Storage)
  Paperclip.options[:command_path] = "/usr/bin/" if defined?(Paperclip)

  # Enable locale fallbacks for I18n
  config.i18n.fallbacks = true

  # Do not dump schema after migrations.
  config.active_record.dump_schema_after_migration = false

  # Disable ActiveRecord Logging (preserved from Rails 7)
  config.active_record.logger = nil

  # Only use :id for inspections in production (Rails 8 feature)
  config.active_record.attributes_for_inspect = [:id]

  # Enable DNS rebinding protection and other `Host` header attacks.
  # config.hosts = [
  #   "example.com",     # Allow requests from example.com
  #   /.*\.example\.com/ # Allow requests from subdomains like `www.example.com`
  # ]
  #
  # Skip DNS rebinding protection for the default health check endpoint.
  # config.host_authorization = { exclude: ->(request) { request.path == "/up" } }

  # ============================================================================
  # LOGSTASH CONFIGURATION (preserved from Rails 7 - commented out)
  # ============================================================================
  # Uncomment and configure if using Logstash

  # config.lograge.enabled = true
  # config.lograge.keep_original_rails_log = true

  # config.lograge.custom_payload do |controller|
  #   {
  #     host: "Logix",
  #     user_id: controller.current_user.try(:id)
  #   }
  # end

  # config.lograge.formatter = Lograge::Formatters::Logstash.new
  # config.logstash.host = '192.168.11.25'  # Optional, defaults to '0.0.0.0'
  # config.logstash.port = 5000             # Required, the port to connect to
  # config.logstash.type = :tcp             # Required
end
