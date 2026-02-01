# frozen_string_literal: true

class GoogleClassroomController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_google_auth

  def index
    @classroom_service = GoogleClassroomService.new(current_user)
    @teacher_courses = @classroom_service.teacher_courses
    @connection_test = @classroom_service.test_connection
  end

  private

    def ensure_google_auth
      return if current_user.provider == "google_oauth2" && current_user.google_access_token.present?

      redirect_to user_google_oauth2_omniauth_authorize_path,
                  alert: "Please connect your Google account to use Classroom integration."
    end
end
