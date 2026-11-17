# frozen_string_literal: true

class Collaboration < ApplicationRecord
  belongs_to :user
  belongs_to :project

  # Creates the collaboration and notifies the added user when the project belongs to an assignment.
  # @param project [Project]
  # @param user [User] the user being added
  # @param added_by [User] the user adding the collaborator
  # @return [Collaboration]
  def self.create_and_notify_assignment_collaborator(project:, user:, added_by:)
    transaction do
      collaboration = where(project: project, user: user).first_or_create
      collaboration.notify_assignment_collaborator(added_by) if collaboration.previously_new_record?
      collaboration
    end
  end

  # Sends an in-app notification to the collaborator when the project belongs to an assignment.
  # @param added_by [User]
  # @return [void]
  def notify_assignment_collaborator(added_by)
    assignment = project.assignment
    return if assignment.nil?

    AssignmentCollaboratorNotification.with(user: added_by.name, assignment: assignment).deliver_later(user)
  end
end
