# frozen_string_literal: true

module FlipperHelpers
  def flipper_enable(feature, actor = nil)
    actor ? Flipper[feature].enable(actor) : Flipper[feature].enable
  end

  def flipper_disable(feature, actor = nil)
    actor ? Flipper[feature].disable(actor) : Flipper[feature].disable
  end
end

RSpec.configure do |config|
  config.include FlipperHelpers
end
