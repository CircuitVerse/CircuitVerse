# frozen_string_literal: true

class QuestionSubmissionHistoriesController < ApplicationController
  before_action :authenticate_user!, only: %i[create]

  def create
    question = Question.find(params[:question_id])
    submission_history = current_user.question_submission_histories.find_or_initialize_by(question: question)

    submission_history.circuit_boilerplate = submission_params[:circuit_boilerplate]
    submission_history.status = submission_params[:status]

    if submission_history.save
      render json: { message: "Submission history created successfully", data: submission_history }, status: :created
    else
      render json: { error: submission_history.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def fetch_submission_or_question
    question = Question.find(params[:question_id])

    if user_signed_in?
      user = find_user
      submission_history = find_submission_history(user, question)
      render_submission_or_question(question, submission_history)
    else
      render_question(question)
    end
  end

  private

    def submission_params
      params.require(:question_submission_history).permit(:circuit_boilerplate, :status)
    end

    def find_user
      params[:user_id].present? ? User.find(params[:user_id]) : current_user
    end

    def find_submission_history(user, question)
      QuestionSubmissionHistory.find_by(user_id: user.id, question_id: question.id)
    end

    def render_submission_or_question(question, submission_history)
      if submission_history
        render json: submission_history_data(question, submission_history), status: :ok
      else
        render_question(question)
      end
    end

    def render_question(question)
      render json: question_data(question), status: :ok
    end

    def submission_history_data(question, submission_history)
      {
        question_id: question.id,
        heading: question.heading,
        statement: question.statement,
        circuit_boilerplate: submission_history.circuit_boilerplate,
        test_data: question.test_data
      }
    end

    def question_data(question)
      {
        question_id: question.id,
        heading: question.heading,
        statement: question.statement,
        circuit_boilerplate: question.circuit_boilerplate,
        test_data: question.test_data
      }
    end
end
