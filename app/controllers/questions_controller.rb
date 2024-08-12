# frozen_string_literal: true

class QuestionsController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_moderator, only: %i[create update destroy]
  before_action :set_question, only: %i[show edit update destroy]
  before_action :check_question_bank, only: %i[index show edit update destroy]

  def index
    @questions = Question.all
    @questions = Question.paginate(page: params[:page], per_page: 6)
    @questions = @questions.where(category_id: params[:category_id]) if params[:category_id].present?
    @questions = @questions.where(difficulty_level: params[:difficulty_level]) if params[:difficulty_level].present?
    if params[:q].present?
      @questions = @questions.where("heading LIKE :query OR statement LIKE :query",
                                    query: "%#{params[:q]}%")
    end

    @categories = QuestionCategory.all
    render :index
  end

  def check_question_bank
    return unless Flipper.enabled?(:question_bank)

    api_error(status: 403, errors: "Question bank is currently blocked")
  end

  def show
    render json: @question
  end

  def new
    if Flipper.enabled?(:question_bank)
      redirect_to root_path, alert: "Question bank is currently blocked"
    else
      @question = Question.new(qid: params[:qid])
      render :new
    end
  end

  def edit
    @question = Question.find(params[:id])
    if @question.nil?
      redirect_to questions_path, alert: "Question not found"
    else
      render :edit
    end
  end

  def create
    @question = Question.new(question_params)
    if @question.save
      flash[:notice] = "Question has been added"
      redirect_to root_path
    else
      render :new
    end
  end

  def update
    @question = Question.find(params[:id])
    if @question.update(question_params)
      redirect_to questions_path, notice: "Question was successfully updated."
    else
      render :edit_by_qid
    end
  end

  def destroy
    @question.destroy
    flash[:notice] = "Question has been deleted"
    redirect_to questions_path
  end

  private

    def authorize_moderator
      Rails.logger.debug current_user
      Rails.logger.debug current_user&.question_bank_moderator?
      return if current_user&.question_bank_moderator?

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
        :difficulty_level,
        :qid,
        :test_data,
        :circuit_boilerplate
      )
    end
end
