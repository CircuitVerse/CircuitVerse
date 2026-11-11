# frozen_string_literal: true

class Collaboration < ApplicationRecord
  belongs_to :user
  belongs_to :project

  def notify_assignment_collaborator(added_by)
    assignment = project.assignment
    return if assignment.nil?

    AssignmentCollaboratorNotification.with(user: added_by, assignment: assignment).deliver_later(user)
  end
end
