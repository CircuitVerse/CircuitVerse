# frozen_string_literal: true

module FlipperHelpers
  def flipper_enable(feature = :contests, actor = nil)
    Flipper.enable(feature, actor)
  end

  def flipper_disable(feature = :contests, actor = nil)
    Flipper.disable(feature, actor)
  end

  def enable_contests!
    flipper_enable(:contests)
  end
end

RSpec.configure do |config|
  config.include FlipperHelpers

  config.before(:each) { Flipper.disable(:contests) }
end
