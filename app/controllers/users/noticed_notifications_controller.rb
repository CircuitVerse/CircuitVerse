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
    recipient.update!(star: "true", fork: "true")
    redirect_back(fallback_location: root_path)
  end

  def disable
    recipient = current_user
    recipient.update!(star: "false", fork: "false")
    redirect_back(fallback_location: root_path)
  end

  def enable_star
    recipient = current_user
    recipient.update!(star: "true")
    redirect_back(fallback_location: root_path)
  end

  def enable_fork
    recipient = current_user
    recipient.update!(fork: "true")
    redirect_back(fallback_location: root_path)
  end

  def disable_star
    recipient = current_user
    recipient.update!(star: "false")
    redirect_back(fallback_location: root_path)
  end

  def disable_fork
    recipient = current_user
    recipient.update!(fork: "false")
    redirect_back(fallback_location: root_path)
  end

  def edit
    @user = User.find(params[:id])
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
