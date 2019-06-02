# frozen_string_literal: true

class GradesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_grade, only: [:create, :destroy]

  def create
    @grade = @grade.present? ? @grade : Grade.new(assignment_id: grade_params[:assignment_id])

    authorize @grade, :mentor?

    @grade.project_id = grade_params[:project_id]
    @grade.grade = grade_params[:grade]
    @grade.assignment_id = grade_params[:assignment_id]
    @grade.user_id = current_user.id

    @grade.save
  end

  def destroy
    if @grade.present?
      authorize @grade, :mentor?
      @grade.destroy
    end

    render json: {}, status: 200
  end

  private
    def grade_params
      params.require(:grade).permit(:project_id, :grade, :assignment_id)
    end

    def grade_udpate_params
      params.require(:grade).permit(:grade, :user_id, :project_id)
    end

    def set_grade
      @grade = Grade.find_by(project_id: grade_params[:project_id])
    end
end
