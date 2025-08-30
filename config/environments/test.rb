# SimpleCov configuration (preserved from Rails 7)
require "simplecov"
require "simplecov-lcov"
SimpleCov::Formatter::LcovFormatter.config.report_with_single_file = true
SimpleCov.formatter = SimpleCov::Formatter::LcovFormatter
SimpleCov.start do
  add_filter(/^\/spec\//) # For RSpec, use `test` for MiniTest
  enable_coverage(:branch)
end

# The test environment is used exclusively to run your application's
# test suite. You never need to work with it otherwise. Remember that
# your test database is "scratch space" for the test suite and is wiped
# and recreated between test runs. Don't rely on the data there!

Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # While tests run files are not watched, reloading is not necessary.
  config.enable_reloading = false

  # Eager loading loads your entire application. When running a single test locally,
  # this is usually not necessary, and can slow down your test suite. However, it's
  # recommended that you enable it in continuous integration systems to ensure eager
  # loading is working properly before deploying your code.
  config.eager_load = ENV["CI"].present? || true  # Keep true as per original for compatibility

  # Configure public file server for tests with cache-control for performance.
  config.public_file_server.enabled = true
  config.public_file_server.headers = { "cache-control" => "public, max-age=3600" }

  # Show full error reports.
  config.consider_all_requests_local = true

  # Disable caching in tests
  config.action_controller.perform_caching = false
  config.cache_store = :null_store

  # Render exception templates for rescuable exceptions and raise for other exceptions.
  # Using :none to maintain Rails 7 behavior of not showing exceptions
  config.action_dispatch.show_exceptions = :none

  # Disable request forgery protection in test environment.
  config.action_controller.allow_forgery_protection = false

  # Store uploaded files on the local file system in a temporary directory.
  config.active_storage.service = :test

  # Tell Action Mailer not to deliver emails to the real world.
  # The :test delivery method accumulates sent emails in the
  # ActionMailer::Base.deliveries array.
  config.action_mailer.delivery_method = :test
  config.action_mailer.perform_caching = false

  # Set host to be used by links generated in mailer templates.
  config.action_mailer.default_url_options = { host: "example.com" }

  # Use test queue adapter for Active Job
  config.active_job.queue_adapter = :test

  # Print deprecation notices to the stderr.
  config.active_support.deprecation = :stderr

  # Raises error for missing translations.
  # config.i18n.raise_on_missing_translations = true

  # Annotate rendered view with file names.
  # config.action_view.annotate_rendered_view_with_filenames = true

  # Raise error when a before_action's only/except options reference missing actions.
  config.action_controller.raise_on_missing_callback_actions = true

  # ============================================================================
  # CUSTOM CIRCUITVERSE TEST CONFIGURATIONS (preserved from Rails 7)
  # ============================================================================

  # Disable Rack::Attack in test env to not throttle tests
  config.middleware.delete Rack::Attack if defined?(Rack::Attack)

  # Web Push (VAPID) test keys (preserved from Rails 7)
  config.vapid_public_key = "BP0eSFqHWrs8xtF96UegaSl5rZJDbPkRen_9oQPZfq9q6iFmbwuELSKqm89qydRcG_F5xSsavxvbGyh_ci9_SQM="
  config.vapid_private_key = "uGNkt259yGQDgGQYP1R4r3q1vTKkCddZe3rImyZvM4w="

  # Asset compression (if using Sprockets)
  config.assets.css_compressor = nil if defined?(Sprockets)
end
