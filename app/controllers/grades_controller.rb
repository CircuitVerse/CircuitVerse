# frozen_string_literal: true

class GradesController < ApplicationController
  include ActionView::Helpers::SanitizeHelper

  before_action :authenticate_user!
  before_action :set_grade, only: %i[create destroy]
  before_action :set_assignment, only: [:to_csv]

  def create
    @grade = @grade.presence || Grade.new(assignment_id: grade_params[:assignment_id])

    authorize @grade, :mentor?

    grade = sanitize grade_params[:grade].presence || @grade.grade
    remarks = sanitize grade_params[:remarks].presence || @grade.remarks

    @grade.project_id = grade_params[:project_id]
    @grade.grade = grade
    @grade.assignment_id = grade_params[:assignment_id]
    @grade.user_id = current_user.id
    @grade.remarks = remarks

    unless @grade.save
      render json: { error: "Grade is invalid" }, status: :bad_request
      return
    end

    return unless Flipper.enabled?(:lms_integration, current_user) && session[:is_lti]

    project = Project.find(grade_params[:project_id])
    assignment = Assignment.find(grade_params[:assignment_id])
    submit_grade_to_lms(project, assignment, grade)
  end

  def destroy
    project_id = @grade&.project_id
    if @grade.present?
      authorize @grade, :mentor?
      @grade.destroy
    end

    render json: { project_id: project_id }, status: :ok
  end

  def to_csv
    unless policy(@assignment).can_be_graded?
      raise ApplicationPolicy::CustomAuthException, "Assignment cannot be graded yet"
    end

    respond_to do |format|
      format.csv do
        send_data Grade.to_csv(@assignment.id),
                  filename: "#{@assignment.name} grades.csv"
      end
    end
  end

  private

   
    def submit_grade_to_lms(project, assignment, grade)
      return if project.lis_result_sourced_id.blank?
      return if project.assignment_id != assignment.id
      return unless lti_11_context_for_project?(project)

      score = grade.to_f / 100 # 0-1 scale per IMS Basic Outcomes
      LtiScoreSubmission.new(
        assignment: assignment,
        lis_result_sourced_id: project.lis_result_sourced_id,
        score: score,
        lis_outcome_service_url: session[:lis_outcome_service_url]
      ).call
    rescue StandardError => e
      # the grade is already persisted; a failed passback must not fail the request
      Rails.logger.error(
        "LTI grade passback failed for assignment #{assignment.id}: #{e.class} #{e.message}"
      )
    end

    def lti_11_context_for_project?(project)
      session[:lis_outcome_service_url].present? &&
        session[:lti_11_assignment_id].to_i == project.assignment_id
    end

    def grade_params
      params.expect(grade: %i[project_id grade assignment_id remarks])
    end

    def set_grade
      @grade = Grade.find_by(project_id: grade_params[:project_id],
                             assignment_id: grade_params[:assignment_id])
    end

    def set_assignment
      @assignment = Assignment.find(params.expect(:assignment_id))
    end
end
