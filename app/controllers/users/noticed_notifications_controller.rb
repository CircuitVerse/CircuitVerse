# frozen_string_literal: true

class Users::NoticedNotificationsController < ApplicationController
  before_action :authenticate_user!

  def index
    @notifications = NoticedNotification.where(recipient: current_user).newest_first
    @unread = NoticedNotification.where(recipient: current_user).newest_first.unread
  end

  def mark_as_read
    notification = NoticedNotification.find(params[:id])
    notification.update(read_at: Time.zone.now)
    notification.save!
    if notification.params[:migrated] == true
      project = Project.find(notification.params[:project_id])
    else
      project = Project.find(notification.params[:project][:id])
    end
    redirect_to user_project_path(project.author, project)
  end

  def mark_all_as_read
    NoticedNotification.where(recipient: current_user).update_all(read_at: Time.zone.now)
    redirect_to notifications_path(current_user)
  end
end
