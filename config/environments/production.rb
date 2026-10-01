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

  # App JS/CSS is bundled by esbuild/dart-sass into app/assets/builds and served
  # precompiled by Propshaft.

  # Log configuration
  config.log_tags = [:request_id]
  # Default to :info in production; override with RAILS_LOG_LEVEL (e.g. "debug")
  # when troubleshooting.
  config.log_level = ENV.fetch("RAILS_LOG_LEVEL", "info")

  # If logging to STDOUT
  if ENV["RAILS_LOG_TO_STDOUT"].present?
    config.logger = ActiveSupport::TaggedLogging.logger(STDOUT)
  end

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
  config.action_mailer.default_url_options = { host: "https://circuitverse.org/" }
  config.action_mailer.asset_host = "https://circuitverse.org"

  # Amazon SES email delivery. Presence of credentials is validated at boot
  # (see config/initializers/secrets_validation.rb).
  if ENV["AWS_ACCESS_KEY_ID_SES"].present? && ENV["AWS_SECRET_ACCESS_KEY_SES"].present?
    config.action_mailer.delivery_method = :ses_v2
    config.action_mailer.ses_v2_settings = {
      credentials: Aws::Credentials.new(ENV["AWS_ACCESS_KEY_ID_SES"], ENV["AWS_SECRET_ACCESS_KEY_SES"])
    }
  end

  # Web Push (VAPID) configuration (preserved from Rails 7)
  config.vapid_public_key = ENV["VAPID_PUBLIC_KEY"] || ""
  config.vapid_private_key = ENV["VAPID_PRIVATE_KEY"] || ""

  # CSRF origin check (preserved from Rails 7)
  config.action_controller.forgery_protection_origin_check = false

 

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

  # Structured logging: every log line is already tagged with the request ID
  # via config.log_tags above. For lograge-style request-level structured
  # logging, add the `lograge` gem to the Gemfile and enable it here.
end
