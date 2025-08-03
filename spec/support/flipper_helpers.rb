# frozen_string_literal: true

module FlipperHelpers
  def flipper_enable(feature = :contests, actor = nil)
    Flipper[feature].enable(actor)
  end

  def flipper_disable(feature = :contests, actor = nil)
    Flipper[feature].disable(actor)
  end

  def enable_contests!
    flipper_enable(:contests)
  end
end

RSpec.configure do |config|
  config.include FlipperHelpers
end
