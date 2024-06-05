# frozen_string_literal: true

class Api::V1::QuestionsController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_moderator, only: %i[create update destroy]
  before_action :set_question, only: %i[update destroy]

  # POST /api/v1/questions
  def create
    @question = Question.new
    @question.heading = question_params[:heading]
    @question.statement = question_params[:statement]
    @question.category_id = question_params[:category_id]
    @question.difficulty_level_id = question_params[:difficulty_level_id]
    @question.test_data = question_params[:test_data]
    @question.circuit_boilerplate = question_params[:circuit_boilerplate]
    if @question.save
      render json: @question, status: :created
    else
      render json: @question.errors, status: :unprocessable_entity
    end
  end

  # PUT /api/v1/questions/:id
  def update
    @question.assign_attributes(
      heading: question_params[:heading],
      statement: question_params[:statement],
      category_id: question_params[:category_id],
      difficulty_level_id: question_params[:difficulty_level_id],
      test_data: question_params[:test_data],
      circuit_boilerplate: question_params[:circuit_boilerplate]
    )
    if @question.save
      render json: @question, status: :ok
    else
      render json: @question.errors, status: :unprocessable_entity
    end
  end

  # DELETE /api/v1/questions/:id
  def destroy
    @question.destroy
    head :no_content
  end

  private

    def authorize_moderator
      return if current_user.question_bank_moderator?

      render json: { error: "Unauthorized" }, status: :unauthorized
    end

    def set_question
      @question = Question.find(params[:id])
    end

    def question_params
      params.require(:question).permit(
        :heading,
        :statement,
        :category_id,
        :difficulty_level_id,
        test_data: {},
        circuit_boilerplate: {}
      )
    end
end
