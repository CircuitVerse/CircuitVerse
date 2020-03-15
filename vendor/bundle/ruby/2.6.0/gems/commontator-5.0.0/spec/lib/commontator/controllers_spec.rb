require 'rails_helper'

module Commontator
  RSpec.describe Controllers, type: :lib do
    it 'must add commontator_thread_show to ActionController instances' do
      expect(ActionController::Base.new.respond_to?(:commontator_thread_show,
                                                    true)).to eq true
      expect(DummyModelsController.new.respond_to?(:commontator_thread_show,
                                                   true)).to eq true
    end

    it 'must add shared helper to ActionController and subclasses' do
      expect(ActionController::Base.helpers).to respond_to(:commontator_thread)
      expect(DummyModelsController.helpers).to respond_to(:commontator_thread)
    end
  end
end

