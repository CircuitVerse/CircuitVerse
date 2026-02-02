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

def sync_assignments
  course_id = params[:course_id]
  group_id = params[:group_id]
  
  @group = Group.find(group_id)
  # Check if user owns this group
  unless @group.primary_mentor == current_user
    return redirect_to google_classroom_index_path, alert: 'You can only sync assignments for your own groups.'
  end

  @classroom_service = GoogleClassroomService.new(current_user)
  assignments = @classroom_service.course_assignments(course_id)

  synced_count = 0
  assignments.each do |coursework|
    # Skip if assignment already exists
    next if @group.assignments.exists?(google_classroom_id: coursework.id)
    
    assignment = @group.assignments.build(
      name: coursework.title,
      description: coursework.description || "Synced from Google Classroom",
      deadline: parse_google_due_date(coursework.due_date, coursework.due_time),
      grading_scale: 'percent',
      status: 'open',
      google_classroom_id: coursework.id
    )
    
    if assignment.save
      synced_count += 1
    else
      Rails.logger.error "Failed to sync assignment: #{assignment.errors.full_messages}"
    end
  end

  redirect_to group_path(@group), 
              notice: "#{synced_count} assignments synced from Google Classroom."
end


  def push_assignment
    assignment_id = params[:assignment_id]
    course_id = params[:course_id]

    @assignment = Assignment.find(assignment_id)
    @group = @assignment.group

    # Check if user owns this group
    unless @group.primary_mentor == current_user
      return redirect_to google_classroom_index_path, alert: "You can only push assignments from your own groups."
    end

    @classroom_service = GoogleClassroomService.new(current_user)

    assignment_params = {
      title: @assignment.name,
      description: @assignment.description || "Created in CircuitVerse",
      due_date: @assignment.deadline,
      due_time: @assignment.deadline
    }

    coursework = @classroom_service.create_assignment(course_id, assignment_params)

    if coursework
      @assignment.update(google_classroom_id: coursework.id)
      redirect_to assignment_path(@assignment),
                  notice: "Assignment pushed to Google Classroom successfully!"
    else
      redirect_to assignment_path(@assignment),
                  alert: "Failed to push assignment to Google Classroom."
    end
  end

  private

    def parse_google_due_date(due_date, due_time)
  # Always return a valid date - never nil
  return 1.week.from_now unless due_date

  begin
    date = Date.new(due_date.year, due_date.month, due_date.day)
    if due_time && due_time.hours && due_time.minutes
      time_str = "#{due_time.hours}:#{due_time.minutes}:00"
      DateTime.parse("#{date} #{time_str}")
    else
      date.end_of_day
    end
  rescue => e
    Rails.logger.error "Error parsing Google due date: #{e.message}"
    1.week.from_now # Default fallback
  end
end

  private

    def ensure_google_auth
      return if current_user.provider == "google_oauth2" && current_user.google_access_token.present?

      redirect_to user_google_oauth2_omniauth_authorize_path,
                  alert: "Please connect your Google account to use Classroom integration."
    end
end
