# frozen_string_literal: true

class Users::NoticedNotificationsController < ApplicationController
  before_action :authenticate_user!

  def index
    @notifications = NoticedNotification.where(recipient: current_user).newest_first.paginate(page: params[:page], per_page: 10)
    @unread = NoticedNotification.where(recipient: current_user).newest_first.unread.paginate(page: params[:page], per_page: 10)
  end

  def mark_as_read
    notification = NoticedNotification.find(params[:notification_id])
    notification.update(read_at: Time.zone.now)
    answer = NotifyUser.new(params).call
    return redirect_to group_assignment_path(answer.first_param, answer.second) if answer.type == "new_assignment"

    redirect_to user_project_path(answer.first_param, answer.second)
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
