# frozen_string_literal: true

class Api::V1::GradesController < Api::V1::BaseController
  include ActionView::Helpers::SanitizeHelper

  before_action :authenticate_user!
  before_action :load_create_resources, only: %i[create]
  before_action :set_grade, only: %i[update destroy]
  before_action :check_access

  def create
    @grade.user_id = current_user.id
    @grade.grade = grade_params[:grade]
    @grade.remarks = sanitize grade_params[:remarks]

    if @grade.save
      render json: Api::V1::GradeSerializer.new(@grade), status: :created
    else
      api_error(status: 422, errors: @grade.errors)
    end
  end

  def update
    @grade.update!(grade_params)
    render json: Api::V1::GradeSerializer.new(@grade), status: :accepted
  end

  def destroy
    @grade.destroy!
    render status: :no_content
  end

  private

    def load_create_resources
      @grade = Grade.new(
        assignment_id: params[:assignment_id], project_id: params[:project_id]
      )
    end

    def set_grade
      @grade = Grade.find(params[:id])
    end

    def check_access
      authorize @grade, :mentor?
    end

    def grade_params
      params.require(:grade).permit(:grade, :remarks)
    end
end
