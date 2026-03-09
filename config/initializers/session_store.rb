Rails.application.config.session_store :redis_session_store,
  key: '_circuitverse_session',
  redis: {
    url: ENV.fetch("REDIS_URL") { "redis://localhost:6379/" },
    expire_after: 90.minutes
  }
