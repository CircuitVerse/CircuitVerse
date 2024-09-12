class QuestionSubmissionHistoriesController < ApplicationController
  before_action :authenticate_user!, only: %i[create]

  def create
    question = Question.find(params[:question_id])
    submission_history = current_user.question_submission_histories.find_or_initialize_by(question: question)

    submission_history.circuit_boilerplate = submission_params[:circuit_boilerplate]
    submission_history.status = submission_params[:status]

    if submission_history.save
      render json: { message: 'Submission history created successfully', data: submission_history }, status: :created
    else
      render json: { error: submission_history.errors.full_messages }, status: :unprocessable_entity
    end
  end
  
  def fetch_submission_or_question
    question = Question.find(params[:question_id])
    
    if user_signed_in?
      user = params[:user_id].present? ? User.find(params[:user_id]) : current_user
      submission_history = QuestionSubmissionHistory.find_by(user: user, question: question)

      if submission_history
        render json: {
          question_id: question.id,
          heading: question.heading,
          statement: question.statement,
          circuit_boilerplate: submission_history.circuit_boilerplate,
          test_data: question.test_data
        }, status: :ok
      else
        render json: {
          question_id: question.id,
          heading: question.heading,
          statement: question.statement,
          circuit_boilerplate: question.circuit_boilerplate,
          test_data: question.test_data
        }, status: :ok
      end
    else
      render json: {
        question_id: question.id,
        heading: question.heading,
        statement: question.statement,
        circuit_boilerplate: question.circuit_boilerplate,
        test_data: question.test_data
      }, status: :ok
    end
  end

  private

  def submission_params
    params.require(:question_submission_history).permit(:circuit_boilerplate, :status)
  end
end
