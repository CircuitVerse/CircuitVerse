# frozen_string_literal: true

module ProjectComponents
  class DeleteProjectConfirmationModelComponent < ViewComponent::Base
    # This component has been deprecated in favor of DeleteComponents::DeleteConfirmationModalComponent
    # It is maintained here for backwards compatibility only
    def call
      render(DeleteComponents::DeleteConfirmationModalComponent.new(
        modal_id: "deleteprojectModal",
        message_key: "projects.delete_project_message",
        button_id: "projects-delete-button",
        delete_path: "#"
      ))
    end
  end
end
