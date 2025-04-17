# frozen_string_literal: true

class DeleteModalComponent < ViewComponent::Base
    def initialize(id:, message:, delete_path:, button_id:)
      @id = id
      @message = message
      @delete_path = delete_path
      @button_id = button_id
    end
  end
  