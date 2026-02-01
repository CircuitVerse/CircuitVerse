# frozen_string_literal: true

class Avo::Actions::CloseAssignment < Avo::BaseAction
  self.name = "Close Assignment"
  self.message = "Close selected assignments?"
  self.confirm_button_label = "Close"
  self.cancel_button_label = "Cancel"

  def handle(query:, _fields:, _current_user:, _resource:, **_args)
    query.each do |assignment|
      assignment.update!(status: "closed")
    end

    succeed "Closed #{query.count} assignment(s)"
  end
end
