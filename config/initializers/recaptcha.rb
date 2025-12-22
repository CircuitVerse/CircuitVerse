# frozen_string_literal: true

Recaptcha.configure do |config|
  config.site_key = ENV["RECAPTCHA_SITE_KEY"]
  config.secret_key = ENV["RECAPTCHA_SECRET_KEY"]

  # Skip verification in test environment to avoid network calls and flakiness
  config.skip_verify_env << "test" if Rails.env.test?
end
