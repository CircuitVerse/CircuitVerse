# frozen_string_literal: true

class Users::NotificationsController < ApplicationController
  before_action :authenticate_user!

  def index
    @notifications = Notification.where(recipient: current_user).newest_first
    @unread = Notification.where(recipient: current_user).newest_first.unread
  end

  def mark_all_as_read
    Notification.where(recipient: current_user).update_all(read_at: Time.zone.now)
    redirect_to notifications_path(current_user)
  end
end
