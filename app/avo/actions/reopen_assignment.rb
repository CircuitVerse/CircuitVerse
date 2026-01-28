# frozen_string_literal: true

class Avo::Actions::ReopenAssignment < Avo::BaseAction
  self.name = "Reopen Assignment"
  self.message = "Reopen selected assignments?"
  self.confirm_button_label = "Reopen"
  self.cancel_button_label = "Cancel"

  def handle(query:, _fields:, _current_user:, _resource:, **_args)
    query.each do |assignment|
      assignment.update!(status: "open")
    end

    succeed "Reopened #{query.count} assignment(s)"
  end
end
