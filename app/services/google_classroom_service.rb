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
    Rails.logger.error "Google Classroom API error during connection test: #{e.message}"
    { success: false, message: "An error occurred while connecting to Google Classroom" }
  rescue StandardError => e
    Rails.logger.error "Google Classroom connection error: #{e.message}"
    { success: false, message: "An error occurred while connecting to Google Classroom" }
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

  # Get coursework (assignments) for a course
  def course_assignments(course_id)
    response = @service.list_course_works(course_id)
    # Filter only assignments (not questions or materials)
    all_coursework = response.course_work || []
    all_coursework.select { |work| work.work_type == "ASSIGNMENT" }
  rescue Google::Apis::Error => e
    Rails.logger.error "Google Classroom API error: #{e.message}"
    []
  end

  # Create coursework in Google Classroom
  def create_assignment(course_id, assignment_params)
    coursework = Google::Apis::ClassroomV1::CourseWork.new(
      title: assignment_params[:title],
      description: assignment_params[:description],
      work_type: "ASSIGNMENT",
      state: "PUBLISHED"
    )

    # Add due date if provided
    if assignment_params[:due_date]
      due_date = assignment_params[:due_date].to_date
      coursework.due_date = Google::Apis::ClassroomV1::Date.new(
        year: due_date.year,
        month: due_date.month,
        day: due_date.day
      )

      if assignment_params[:due_time]
        due_time = assignment_params[:due_time]
        due_time = Time.parse(due_time) if due_time.is_a?(String)
        coursework.due_time = Google::Apis::ClassroomV1::TimeOfDay.new(
          hours: due_time.hour,
          minutes: due_time.min
        )
      end
    end

    @service.create_course_work(course_id, coursework)
  rescue Google::Apis::Error => e
    Rails.logger.error "Google Classroom API error: #{e.message}"
    nil
  end

  # Submit grade for a student submission
  def submit_grade(course_id, coursework_id, student_email, grade)
    # First, get the student submissions for this coursework
    submissions = @service.list_course_course_work_student_submissions(
      course_id, coursework_id, user_id: student_email
    ).student_submissions

    return false if submissions.empty?

    student_submission = submissions.first

    # Set numeric grades directly on the StudentSubmission
    student_submission.assigned_grade = grade.to_f
    student_submission.draft_grade = grade.to_f

    @service.patch_course_course_work_student_submission(
      course_id, coursework_id, student_submission.id, student_submission,
      update_mask: "assignedGrade,draftGrade"
    )

    true
  rescue Google::Apis::Error => e
    Rails.logger.error "Google Classroom grade submission error: #{e.message}"
    false
  end

  # Get student submissions for an assignment
  def get_student_submissions(course_id, coursework_id)
    @service.list_course_course_work_student_submissions(
      course_id, coursework_id
    ).student_submissions || []
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
          "https://www.googleapis.com/auth/classroom.courses.readonly",
          "https://www.googleapis.com/auth/classroom.coursework.students",
          "https://www.googleapis.com/auth/classroom.coursework.students.readonly"
        ]
      )

      auth.access_token = @user.google_access_token
      auth.refresh_token = @user.google_refresh_token

      # Set expiration time if available
      if @user.respond_to?(:google_token_expires_at) && @user.google_token_expires_at.present?
        auth.expires_at = @user.google_token_expires_at.to_i
      end

      # Refresh token if expired and refresh token is available
      if auth.expired? && auth.refresh_token.present?
        begin
          auth.refresh!
          # Update user with new tokens
          update_attrs = {
            google_access_token: auth.access_token
          }
          # Only update expires_at if column exists
          if @user.respond_to?(:google_token_expires_at=)
            update_attrs[:google_token_expires_at] = Time.at(auth.expires_at)
          end
          @user.update(update_attrs)
        rescue => e
          Rails.logger.error "Failed to refresh Google token: #{e.message}"
          return nil
        end
      end

      auth
    end
end
