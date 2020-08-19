# frozen_string_literal: true

class GradesController < ApplicationController
  include ActionView::Helpers::SanitizeHelper

  before_action :authenticate_user!
  before_action :set_grade, only: %i[create destroy]

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
      render json: { error: "Grade is invalid" },
             status: :bad_request
    end
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
    respond_to do |format|
      format.csv do
        send_data Grade.to_csv(params[:assignment_id].to_i),
                  filename: "assignment-grades.csv"
      end
    end
  end

  private

    def grade_params
      params.require(:grade).permit(:project_id, :grade, :assignment_id, :remarks)
    end

    def set_grade
      @grade = Grade.find_by(project_id: grade_params[:project_id],
                             assignment_id: grade_params[:assignment_id])
    end
end
