# frozen_string_literal: true

RSpec.configure do |config|
  config.before(type: :system) { enable_contests! }
end
