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
    answer = NotifyUser.new(params).call
    case answer.type
    when "new_assignment"
      redirect_to group_assignment_path(answer.first_param, answer.second)
    when "star", "fork"
      redirect_to user_project_path(answer.first_param, answer.second)
    when "forum_comment"
      redirect_to simple_discussion.forum_thread_path(answer.first_param, anchor: "forum_post_#{answer.second}")
    when "forum_thread"
      redirect_to simple_discussion.forum_thread_path(answer.first_param)
    else
      redirect_to root_path
    end
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
