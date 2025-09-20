# frozen_string_literal: true

module FlipperHelpers
  def flipper_enable(feature = :contests, actor = nil)
    actor ? Flipper[feature].enable(actor) : Flipper[feature].enable
  end

  def flipper_disable(feature = :contests, actor = nil)
    actor ? Flipper[feature].disable(actor) : Flipper[feature].disable
  end

  def enable_contests!
    flipper_enable(:contests)
  end

  def enable_explore!
    flipper_enable(:circuit_explore_page)
  end
end

RSpec.configure do |config|
  config.include FlipperHelpers

  config.before do
    Flipper[:circuit_explore_page].enable
  end
end
