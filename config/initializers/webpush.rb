# config/initializers/webpush.rb
vapid_public_key = ENV['VAPID_PUBLIC_KEY']
vapid_private_key = ENV['VAPID_PRIVATE_KEY']

Rails.application.config.x.webpush.vapid_public_key = vapid_public_key
Rails.application.config.x.webpush.vapid_private_key = vapid_private_key
