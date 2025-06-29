# frozen_string_literal: true

module FlipperHelpers
  def enable_contests!
    Flipper.enable(:contests)
  end
end

RSpec.configure do |config|
  config.include FlipperHelpers, type: :request
  config.include FlipperHelpers, type: :system
end
