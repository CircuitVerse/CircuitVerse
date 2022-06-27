Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.
  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Do not eager load code on boot.
  config.eager_load = false

  # Show full error reports.
  config.consider_all_requests_local = true

  # Enable/disable caching. By default caching is disabled.
  if Rails.root.join('tmp/caching-dev.txt').exist?
    config.action_controller.perform_caching = true

    config.cache_store = :memory_store
    config.public_file_server.headers = {
      'Cache-Control' => "public, max-age=#{2.days.seconds.to_i}"
    }
  else
    config.action_controller.perform_caching = false

    config.cache_store = :null_store
  end

  # Don't care if the mailer can't send.
  config.action_mailer.raise_delivery_errors = false

  config.action_mailer.perform_caching = false

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  # Raise an error on page load if there are pending migrations.
  config.active_record.migration_error = :page_load

  # Debug mode disables concatenation and preprocessing of assets.
  # This option may cause significant delays in view rendering with a large
  # number of complex assets.
  config.assets.debug = true

  # Suppress logger output for asset requests.
  config.assets.quiet = true

  # Raises error for missing translations
  # config.action_view.raise_on_missing_translations = true

  # Use an evented file watcher to asynchronously detect changes in source code,
  # routes, locales, etc. This feature depends on the listen gem.
  config.file_watcher = ActiveSupport::EventedFileUpdateChecker

  config.active_job.queue_adapter = :sidekiq
  config.action_mailer.default_url_options = { host: "localhost:3000" }
  config.action_mailer.perform_deliveries = true
  config.action_mailer.raise_delivery_errors = true

  config.action_mailer.smtp_settings = {
    :address              => 'smtp.yandex.com',
    :port                 => 465,
    :domain               => 'yandex.com',
    :user_name            => ENV["CIRCUITVERSE_EMAIL_ID"],
    :password             =>  ENV["CIRCUITVERSE_EMAIL_PASSWORD"],
    :ssl                  => true,
    :authentication       => :login,
    :enable_starttls_auto => true,
  }
  config.action_mailer.delivery_method = :smtp
  if ENV['DOCKER_ENVIRONMENT']
    config.action_mailer.smtp_settings = { :address => "mailcatcher", :port => 1025 }
  else
    config.action_mailer.smtp_settings = { :address => "localhost", :port => 1025 }
  end

  config.vapid_public_key = ENV["VAPID_PUBLIC_KEY"] || "BGxnigbQCa435vZ8_3uFdqLC0XJHXtONgEdI-ydMMs0JaBsnpUfLxR1UDagq6_cDwHyhqjw77tTlp0ULZkx8Xos="
  config.vapid_private_key = ENV["VAPID_PRIVATE_KEY"] || "FkEMkOQHvMybUlCGH-DsOljTJlLzYGb3xEYsFY5Roxk="

  Rails.application.configure do
    # Whitelist gitpod domain in dev envionment
    config.hosts << /.*\.gitpod\.io\Z/
    config.hosts << /.*\Z/ # Whitelist everything in Dev
  end

  Paperclip.options[:command_path] = "/usr/local/bin/"
end
