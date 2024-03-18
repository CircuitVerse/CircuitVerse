# frozen_string_literal: true

class Collaboration < ApplicationRecord
  belongs_to :user
  belongs_to :project
  after_create_commit :notify_recipient
  has_noticed_notifications model_name: "NoticedNotification"
  before_destroy :cleanup_notification
  has_many :notifications, as: :notifiable # rubocop:disable Rails/HasManyOrHasOneDependent

  def notify_recipient
    NewCollaboratorNotification.with(user: project.author, project: project).deliver_later(user)
  end

  def cleanup_notification
    notifications_as_new_collaborator.destroy_all
  end
end
