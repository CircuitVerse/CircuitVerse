# frozen_string_literal: true

class Users::NoticedNotificationsController < ApplicationController
  skip_after_action :verify_authorized

  before_action :authenticate_user!

  def index
    @notifications = NoticedNotification.where(recipient: current_user).newest_first
    @unread = NoticedNotification.where(recipient: current_user).newest_first.unread
  end

  def mark_as_read
    notification = current_user.noticed_notifications.find(params.expect(:notification_id))
    notification.update(read_at: Time.zone.now)
    answer = NotifyUser.new(notification).call
    redirect_to redirect_path_for(answer)
  rescue ActiveRecord::RecordNotFound
    redirect_to notifications_path(current_user), alert: t("notifications.not_found")
  end

  def mark_all_as_read
    NoticedNotification.where(recipient: current_user, read_at: nil).update_all(read_at: Time.zone.now) # rubocop:disable Rails/SkipsModelValidations
    redirect_to notifications_path(current_user)
  end

  def read_all_notifications
    NoticedNotification.where(recipient: current_user, read_at: nil).update_all(read_at: Time.zone.now) # rubocop:disable Rails/SkipsModelValidations
    redirect_back_or_to(root_path)
  end

  private

    def redirect_path_for(answer)
      case answer.type
      when "new_assignment"
        group_assignment_path(answer.first_param, answer.second)
      when "star", "fork"
        user_project_path(answer.first_param, answer.second)
      when "forum_comment", "forum_thread", "forum_discourse"
        "https://circuitverse.discourse.group"
      when "new_contest"
        contest_page_path(answer.first_param)
      when "contest_winner"
        featured_circuits_path
      else
        root_path
      end
    end
end
