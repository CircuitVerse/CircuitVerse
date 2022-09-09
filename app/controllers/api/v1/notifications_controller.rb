# frozen_string_literal: true

class Api::V1::NotificationsController < Api::V1::BaseController
  before_action :authenticate_user!

  # GET /api/v1/notifications
  def index
    @notifications = NoticedNotification.where(recipient: current_user).newest_first
    render json: Api::V1::NotificationSerializer.new(@notifications)
  end

  # PATCH /api/v1/notifications/mark_as_read/:notification_id
  def mark_as_read
    @notification = NoticedNotification.find(params[:notification_id])
    @notification.update(read_at: Time.zone.now)
    render json: Api::V1::NotificationSerializer.new(@notification), status: :created
  end

  # PATCH /api/v1/notifications/mark_all_as_read
  def mark_all_as_read
    NoticedNotification.where(recipient: current_user, read_at: nil).update_all(read_at: Time.zone.now) # rubocop:disable Rails/SkipsModelValidations
    @notifications = NoticedNotification.where(recipient: current_user).newest_first
    render json: Api::V1::NotificationSerializer.new(@notifications)
  end
end
