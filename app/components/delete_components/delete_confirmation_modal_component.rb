# frozen_string_literal: true

module DeleteComponents
  # A reusable ViewComponent for rendering delete confirmation modals.
  #
  # This component generates a Bootstrap modal used to confirm delete (or similar)
  # actions across the application. It supports configurable HTTP methods,
  # AJAX requests, and optional footer dismiss behavior.
  class DeleteConfirmationModalComponent < ViewComponent::Base
    # Initializes the delete confirmation modal component.
    #
    # @param modal_id [String] Unique identifier for the modal element
    # @param message_key [String] I18n key used to fetch the confirmation message
    # @param button_id [String] Unique identifier for the delete button
    # @param delete_path [String] URL/path where the delete request will be sent
    # @param method [Symbol] HTTP method to use (:delete, :put, etc.), defaults to :delete
    # @param remote [Boolean] Whether to send the request via AJAX, defaults to false
    # @param footer_dismiss [Boolean] Whether the modal footer should dismiss the modal, defaults to true
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
