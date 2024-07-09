# frozen_string_literal: true

class QuestionsController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_moderator, only: %i[create update destroy]
  before_action :set_question, only: %i[show update destroy]

  def index
    @questions = Question.all
    render json: @questions
  end

  def show
    render json: @question
  end

  def new
    @question = Question.new(qid: params[:qid])
    render :new
  end

  def create
    @question = Question.new
    @question.heading = question_params[:heading]
    @question.statement = question_params[:statement]
    @question.category_id = question_params[:category_id]
    @question.difficulty_level = question_params[:difficulty_level]
    @question.test_data = JSON.parse(params[:question][:test_data])
    @question.qid = question_params[:qid]
    @question.circuit_boilerplate = JSON.parse(params[:question][:circuit_boilerplate])
    if @question.save
      flash[:notice] = "Question has been added"
      redirect_to root_path
    else
      render json: @question.errors, status: :unprocessable_entity
    end
  end

  def update
    @question.assign_attributes(
      heading: question_params[:heading],
      statement: question_params[:statement],
      category_id: question_params[:category_id],
      difficulty_level: question_params[:difficulty_level],
      test_data: question_params[:test_data],
      circuit_boilerplate: question_params[:circuit_boilerplate]
    )
    if @question.save
      render json: { message: "Question has been added", redirect_url: root_path }, status: :created
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
    @questions = @questions.where(difficulty_level: params[:difficulty_level]) if params[:difficulty_level].present?
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
      @question = Question.find(params[:qid])
    end

    def question_params
      params.require(:question).permit(
        :heading,
        :statement,
        :category_id,
        :difficulty_level,
        :qid,
        test_data: {},
        circuit_boilerplate: {}
      )
    end
end
