# frozen_string_literal: true

class Users::NoticedNotificationsController < ApplicationController
  before_action :authenticate_user!
  NOTIFICATIONS_PER_PAGE = 10

  def index
    @page = params[:page] || 1
    @notifications = NoticedNotification.where(recipient: current_user)
                                          .newest_first
                                          .paginate(page: @page, per_page: NOTIFICATIONS_PER_PAGE)
    @unread = NoticedNotification.where(recipient: current_user)
                               .newest_first
                               .unread
                               .paginate(page: @page, per_page: NOTIFICATIONS_PER_PAGE)
  end

  def mark_as_read
    notification = NoticedNotification.find(params[:notification_id])
    notification.update(read_at: Time.zone.now)
    answer = NotifyUser.new(params).call
    redirect_to redirect_path_for(answer)
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

    def redirect_path_for(answer) # rubocop:disable Metrics/MethodLength
      case answer.type
      when "new_assignment"
        group_assignment_path(answer.first_param, answer.second)
      when "star", "fork"
        user_project_path(answer.first_param, answer.second)
      when "forum_comment"
        simple_discussion.forum_thread_path(answer.first_param, anchor: "forum_post_#{answer.second}")
      when "forum_thread"
        simple_discussion.forum_thread_path(answer.first_param)
      when "new_contest"
        contest_page_path(answer.first_param)
      when "contest_winner"
        featured_circuits_path
      else
        root_path
      end
    end
end
