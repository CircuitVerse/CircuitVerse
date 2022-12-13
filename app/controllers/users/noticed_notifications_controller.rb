# frozen_string_literal: true

class Users::NoticedNotificationsController < ApplicationController
  before_action :authenticate_user!

  def index
    @notifications = NoticedNotification.where(recipient: current_user).newest_first
    @unread = NoticedNotification.where(recipient: current_user).newest_first.unread
    @user = User.find(params[:id])
  end

  def enable
    recipient = current_user
    notific_type = params[:type]
    if notific_type == "star"
      recipient.update!(star: "true")
    else
      recipient.update!(fork: "true")
    end
    redirect_back(fallback_location: root_path)
  end

  def disable
    recipient = current_user
    notific_type = params[:type]
    if notific_type == "star"
      recipient.update!(star: "false")
    else
      recipient.update!(fork: "false")
    end
    redirect_back(fallback_location: root_path)
  end

  def enable_all
    recipient = current_user
    recipient.update!(star: "true", fork: "true")
    redirect_back(fallback_location: root_path)
  end

  def disable_all
    recipient = current_user
    recipient.update!(star: "false", fork: "false")
    redirect_back(fallback_location: root_path)
  end

  def mark_as_read
    notification = NoticedNotification.find(params[:notification_id])
    notification.update(read_at: Time.zone.now)
    project = notification.params[:project]
    redirect_to user_project_path(project.author, project)
  end

  def mark_all_as_read
    NoticedNotification.where(recipient: current_user, read_at: nil).update_all(read_at: Time.zone.now) # rubocop:disable Rails/SkipsModelValidations
    redirect_to notifications_path(current_user)
  end

  def read_all_notifications
    NoticedNotification.where(recipient: current_user, read_at: nil).update_all(read_at: Time.zone.now) # rubocop:disable Rails/SkipsModelValidations
    redirect_back(fallback_location: root_path)
  end
end
