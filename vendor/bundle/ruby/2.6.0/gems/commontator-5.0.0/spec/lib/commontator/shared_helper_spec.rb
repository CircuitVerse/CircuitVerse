require 'rails_helper'

module Commontator
  RSpec.describe SharedHelper, type: :lib do
    before(:each) do
      setup_controller_spec
    end

    it 'must show commontator thread' do
      @user.can_read = true
      sign_in @user

      controller = DummyModelsController.new

      thread_link = controller.view_context
                              .commontator_thread(DummyModel.create)
      expect(thread_link).not_to be_blank
    end
  end
end

