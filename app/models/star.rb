# frozen_string_literal: true

require "custom_optional_target/web_push"

class Star < ApplicationRecord
  belongs_to :user
  belongs_to :project
  after_create_commit :notify_recipient
  before_destroy :cleanup_notification
  has_noticed_notifications model_name: "NoticedNotification"

  def star_notifiable_path
    user_project_path(project.author, project)
  end

  private

    def notify_recipient
      return if user.id == project.author_id

      StarNotification.with(user: user, project: project).deliver_later(project.author)
    end

    def cleanup_notification
      notifications_as_star.destroy_all
    end
end
