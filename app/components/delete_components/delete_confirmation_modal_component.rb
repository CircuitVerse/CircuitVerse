# frozen_string_literal: true

module DeleteComponents
  class DeleteConfirmationModalComponent < ViewComponent::Base
    def initialize(modal_id:, message_key:, button_id:, delete_path:, method: :delete, remote: false, footer_dismiss: true)
      super()
      @modal_id = modal_id
      @message_key = message_key
      @button_id = button_id
      @delete_path = delete_path
      @method = method
      @remote = remote
      @footer_dismiss = footer_dismiss
    end
  end
end
