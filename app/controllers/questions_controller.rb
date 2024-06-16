# frozen_string_literal: true

class QuestionsController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_moderator, only: %i[create update destroy]
  before_action :set_question, only: %i[update destroy]

  def index
    @questions = Question.all
    render json: @questions
  end

  def show
    render json: @question
  end

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

  def destroy
    @question.destroy
    head :no_content
  end

  def filter
    @questions = Question.all
    @questions = @questions.where(category_id: params[:category_id]) if params[:category_id].present?
    if params[:difficulty_level_id].present?
      @questions = @questions.where(difficulty_level_id: params[:difficulty_level_id])
    end
    render json: @questions
  end

  def status
    case params[:status]
    when "unattempted"
      @questions = Question.where.not(id: current_user.submission_history.pluck("question_id"))
    when "attempted"
      @questions = Question.where(id: current_user.submission_history.pluck("question_id"))
    when "solved"
      solved_question_ids = current_user.submission_history.select do |submission|
        submission["status"] == "solved"
      end.pluck("question_id")
      @questions = Question.where(id: solved_question_ids)
    else
      render json: { error: "Invalid status parameter" }, status: :bad_request
      return
    end
    render json: @questions
  end

  def search
    query = "%#{params[:q]}%"
    @questions = Question.where("heading LIKE :query OR statement LIKE :query", query: query)
    render json: @questions
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
