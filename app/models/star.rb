# frozen_string_literal: true

class Star < ApplicationRecord
  belongs_to :user
  belongs_to :project
  after_create_commit :notify_recipient
  before_destroy :cleanup_notification
  has_many :notifications, as: :notifiable, dependent: :destroy
  has_noticed_notifications model_name: "NoticedNotification"

  private

    def notify_recipient
      return if user.id == project.author_id

      StarNotification.with(user: user, project: project).deliver_later(project.author)
    end

    def cleanup_notification
      notifications_as_star.destroy_all
    end
end
