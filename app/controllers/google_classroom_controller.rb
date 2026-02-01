# frozen_string_literal: true

class GoogleClassroomController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_google_auth

  def index
    @classroom_service = GoogleClassroomService.new(current_user)
    @teacher_courses = @classroom_service.teacher_courses
    @connection_test = @classroom_service.test_connection
  end

  def import_course
    course_id = params[:course_id]
    @classroom_service = GoogleClassroomService.new(current_user)

    course = @classroom_service.course_details(course_id)
    return redirect_to google_classroom_index_path, alert: "Course not found" unless course

    # Create or find group based on Google Classroom course
    @group = Group.find_or_create_by(
      google_classroom_id: course_id,
      primary_mentor: current_user
    ) do |g|
      g.name = course.name
      # Remove description since Group model doesn't have this field
    end

    # Import students
    students = @classroom_service.course_students(course_id)
    imported_count = 0
    pending_count = 0

    students.each do |student|
      # Find user by email
      user = User.find_by(email: student.profile.email_address)
      if user && !@group.users.include?(user)
        GroupMember.create(group: @group, user: user)
        imported_count += 1
      elsif user.nil?
        # Create pending invitation for users not in CircuitVerse
        PendingInvitation.find_or_create_by(
          group: @group,
          email: student.profile.email_address
        )
        pending_count += 1
      end
    end

    message = "Course '#{course.name}' imported successfully! #{imported_count} students added"
    message += ", #{pending_count} invitations sent" if pending_count > 0

    redirect_to group_path(@group), notice: message
  end

  private

    def ensure_google_auth
      return if current_user.provider == "google_oauth2" && current_user.google_access_token.present?

      redirect_to user_google_oauth2_omniauth_authorize_path,
                  alert: "Please connect your Google account to use Classroom integration."
    end
end
