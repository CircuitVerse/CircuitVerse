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

  def enable_yosys_local_gem!
    flipper_enable(:yosys_local_gem)
  end
end

RSpec.configure do |config|
  config.include FlipperHelpers

  config.before do
    Flipper[:circuit_explore_page].enable
    Flipper[:yosys_local_gem].enable
  end
end
