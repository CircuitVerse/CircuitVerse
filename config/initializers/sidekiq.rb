# Note that the client ALWAYS pushes to the new process
Sidekiq.configure_client do |config|
  if ENV['BETA']
    config.redis = { db: 1 }
  else
    config.redis = { db: 0 }
  end
end

Sidekiq.configure_server do |config|
  if ENV['BETA']
    config.redis = { db: 1 }
  else
    config.redis = { db: 0 }
  end
end

