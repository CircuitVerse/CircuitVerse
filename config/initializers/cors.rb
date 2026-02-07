# config/initializers/cors.rb

Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    # Only allow Tauri desktop app
    origins 'tauri://localhost'

    resource '/api/v1/auth/*',
      headers: %w[Authorization Content-Type],
      methods: %i[get post put patch delete options],
      credentials: true,
      max_age: 600
  end
end
