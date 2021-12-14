# frozen_string_literal: true

require "localeapp/rails"

Localeapp.configure do |config|
  config.api_key = ENV["LOCALEAPP_API_KEY"]
end
