# frozen_string_literal: true

class QuestionsController < ApplicationController
  before_action :authenticate_user!, only: %i[create update destroy edit]
  before_action :authorize_moderator, only: %i[create update destroy]
  before_action :set_question, only: %i[show edit update destroy]
  before_action :check_question_bank, only: %i[index show edit update destroy]

  def index
    @questions = filtered_questions.paginate(page: params[:page], per_page: 6)
    filter_by_status if current_user
    @categories = QuestionCategory.all
    render :index
  end

  def check_question_bank
    return if Flipper.enabled?(:question_bank)

    api_error(status: 403, errors: "Question bank is currently blocked")
  end

  def show
    render json: @question
  end

  def new
    if Flipper.enabled?(:question_bank)
      @question = Question.new(qid: params[:qid])
      render :new
    else
      redirect_to root_path, alert: "Question bank is currently blocked"
    end
  end

  def edit; end

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
    return unless @question.update(question_params)

    redirect_to questions_path, notice: "Question was successfully updated."
  end

  def destroy
    @question.destroy
    respond_to do |format|
      format.html { redirect_to questions_url, notice: "Question was successfully deleted." }
    end
  end

  private

    def authorize_moderator
      return if current_user&.question_bank_moderator?

      render json: { error: "Unauthorized" }, status: :unauthorized
    end

    def set_question
      @question = Question.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      redirect_to questions_path, alert: "Question not found"
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

    def api_error(status:, errors:)
      render json: { errors: errors }, status: status
    end

    def filtered_questions
      questions = Question.all
      questions = questions.where(category_id: params[:category_id]) if params[:category_id].present?
      questions = questions.where(difficulty_level: params[:difficulty_level]) if params[:difficulty_level].present?
      questions = questions.where("heading LIKE :query OR statement LIKE :query", query: "%#{params[:q]}%") if params[:q].present?
      questions
    end

    def filter_by_status
      submission_histories = QuestionSubmissionHistory.where(user_id: current_user.id).pluck(:question_id, :status).to_h
      case params[:status]
      when "attempted"
        @questions = @questions.where(id: submission_histories.select { |_, status| status == "attempted" }.keys)
      when "solved"
        @questions = @questions.where(id: submission_histories.select { |_, status| status == "solved" }.keys)
      when "unattempted"
        @questions = @questions.where.not(id: submission_histories.keys)
      end
    end
end