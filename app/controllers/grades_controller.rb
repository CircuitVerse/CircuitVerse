# frozen_string_literal: true

class GradesController < ApplicationController
  include ActionView::Helpers::SanitizeHelper

  before_action :authenticate_user!
  before_action :set_grade, only: [:create, :destroy]

  def create
    @grade = @grade.present? ? @grade : Grade.new(assignment_id: grade_params[:assignment_id])

    authorize @grade, :mentor?

    grade = sanitize grade_params[:grade].present? ? grade_params[:grade] : @grade.grade
    remarks = sanitize grade_params[:remarks].present? ? grade_params[:remarks] : @grade.remarks

    @grade.project_id = grade_params[:project_id]
    @grade.grade = grade
    @grade.assignment_id = grade_params[:assignment_id]
    @grade.user_id = current_user.id
    @grade.remarks = remarks

    render json: { error: "Grade is invalid" },
      status: 400 unless @grade.save
  end

  def destroy
    project_id = @grade&.project_id
    if @grade.present?
      authorize @grade, :mentor?
      @grade.destroy
    end

    render json: { project_id: project_id }, status: 200
  end

  def to_csv
    respond_to do |format|
      format.csv { send_data Grade.to_csv(params[:assignment_id].to_i),
        filename: "assignment-grades.csv" }
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
