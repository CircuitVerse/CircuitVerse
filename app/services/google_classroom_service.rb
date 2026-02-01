# frozen_string_literal: true

require "google/apis/classroom_v1"

class GoogleClassroomService
  include Google::Apis::ClassroomV1

  def initialize(user)
    @user = user
    @service = ClassroomService.new
    @service.authorization = authorization
  end

  # Test method to verify API access
  def test_connection
    courses = @service.list_courses(page_size: 1)
    { success: true, message: "Connected to Google Classroom API", course_count: courses.courses&.size || 0 }
  rescue Google::Apis::Error => e
    { success: false, message: "API Error: #{e.message}" }
  rescue StandardError => e
    { success: false, message: "Connection Error: #{e.message}" }
  end

  # Fetch courses where user is a teacher
  def teacher_courses
    @service.list_courses(teacher_id: @user.email, page_size: 10).courses || []
  rescue Google::Apis::Error => e
    Rails.logger.error "Google Classroom API error: #{e.message}"
    []
  end

  # Get course details
  def course_details(course_id)
    @service.get_course(course_id)
  rescue Google::Apis::Error => e
    Rails.logger.error "Google Classroom API error: #{e.message}"
    nil
  end

  # Get students in a course
  def course_students(course_id)
    @service.list_course_students(course_id).students || []
  rescue Google::Apis::Error => e
    Rails.logger.error "Google Classroom API error: #{e.message}"
    []
  end

  private

    def authorization
      return nil unless @user.provider == "google_oauth2" && @user.google_access_token.present?

      auth = Signet::OAuth2::Client.new(
        client_id: ENV.fetch("GOOGLE_CLIENT_ID", nil),
        client_secret: ENV.fetch("GOOGLE_CLIENT_SECRET", nil),
        token_credential_uri: "https://oauth2.googleapis.com/token",
        scope: [
          "https://www.googleapis.com/auth/classroom.courses.readonly"
        ]
      )

      auth.access_token = @user.google_access_token
      auth.refresh_token = @user.google_refresh_token

      # Refresh token if expired
      if auth.expired? && auth.refresh_token.present?
        auth.refresh!
        @user.update(
          google_access_token: auth.access_token,
          google_refresh_token: auth.refresh_token
        )
      end

      auth
    end
end
