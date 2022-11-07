# frozen_string_literal: true

class Users::NoticedNotificationsController < ApplicationController
  before_action :authenticate_user!

  def index
    @notifications = NoticedNotification.where(recipient: current_user).newest_first
    @unread = NoticedNotification.where(recipient: current_user).newest_first.unread
  end

  def mark_as_read
    notification = NoticedNotification.find(params[:notification_id])
    notification.update(read_at: Time.zone.now)
    case NoticedNotificationType.new(params).notify
    when true
      assignment = notification.params[:assignment]
      group = assignment.group
      redirect_to group_assignment_path(group, assignment)
    when false
      project = notification.params[:project]
      redirect_to user_project_path(project.author, project)
    end
  end

  def mark_all_as_read
    NoticedNotification.where(recipient: current_user, read_at: nil).update_all(read_at: Time.zone.now) # rubocop:disable Rails/SkipsModelValidations
    redirect_to notifications_path(current_user)
  end
end
