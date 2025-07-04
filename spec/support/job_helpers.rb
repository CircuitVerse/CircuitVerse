# frozen_string_literal: true

RSpec.configure do |config|
  config.include ActiveJob::TestHelper, type: %i[job controller helper]
  config.before(type: %i[job controller helper]) { clear_enqueued_jobs }
  config.after(type:  %i[job controller helper]) { clear_enqueued_jobs }
end
