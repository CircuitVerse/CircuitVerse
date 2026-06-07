# frozen_string_literal: true

class Api::V1::AssignmentSubmissionsController < Api::V1::BaseController
  before_action :authenticate_user!
  before_action :set_submission, only: %i[show update]

  # GET /api/v1/assignment_submissions
  # Optional filters: assignment_id, user_id, status
  # Paginated via Kaminari (page/per_page params)
  def index
    scope = AssignmentSubmission.includes(:user, :assignment, :project, :subgroup)

    scope = scope.where(assignment_id: params[:assignment_id]) if params[:assignment_id].present?
    scope = scope.where(user_id: params[:user_id])             if params[:user_id].present?
    scope = scope.where(status: params[:status])               if params[:status].present?

    per_page    = (params[:per_page] || 20).to_i.clamp(1, 100)
    page        = [(params[:page] || 1).to_i, 1].max
    offset      = (page - 1) * per_page
    total_count = scope.count
    total_pages = (total_count / per_page.to_f).ceil

    @submissions = scope.order(created_at: :desc).limit(per_page).offset(offset)

    render json: {
      submissions: @submissions.map { |s| submission_json(s) },
      meta:        { current_page: page, total_pages: total_pages,
                     total_count: total_count, per_page: per_page }
    }
  end

  # GET /api/v1/assignment_submissions/:id
  def show
    render json: submission_json(@submission, detailed: true)
  end

  # PATCH /api/v1/assignment_submissions/:id
  # Mentor-only: update status/score, optionally trigger verification job
  def update
    assignment = @submission.assignment
    group      = assignment.group

    unless current_user.id == group.primary_mentor_id || current_user.admin?
      return render json: { error: "Forbidden" }, status: :forbidden
    end

    if @submission.update(submission_params)
      if @submission.status_graded? && assignment.lti_deployment_id.present?
        Lti::GradePassbackJob.perform_later(@submission.id)
      end
      render json: submission_json(@submission, detailed: true)
    else
      render json: { errors: @submission.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

    def set_submission
      @submission = AssignmentSubmission.includes(:user, :assignment, :project, :subgroup).find(params[:id])
    end

    def submission_params
      params.expect(assignment_submission: %i[status score])
    end

    def submission_json(submission, detailed: false)
      data = {
        id:            submission.id,
        assignment_id: submission.assignment_id,
        user_id:       submission.user_id,
        project_id:    submission.project_id,
        subgroup_id:   submission.subgroup_id,
        status:        submission.status,
        score:         submission.score,
        submitted_at:  submission.submitted_at,
        created_at:    submission.created_at,
        updated_at:    submission.updated_at
      }
      if detailed
        data[:user]       = { id: submission.user.id, name: submission.user.name, email: submission.user.email }
        data[:assignment] = { id: submission.assignment.id, name: submission.assignment.name }
      end
      data
    end

end
