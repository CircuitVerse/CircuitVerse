# frozen_string_literal: true

class Users::NotificationsController < ApplicationController
  before_action :authenticate_user!

  def index
    @notifications = Notification.where(recipient: current_user)
  end
end
