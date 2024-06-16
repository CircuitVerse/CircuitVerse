# frozen_string_literal: true

class QuestionSubmissionController < ApplicationController
  before_action :authenticate_user!

  def post_submission
    submission_params = params.require(:submission).permit(:question_id, :status, :circuit)
    question_id = submission_params[:question_id]
    status = submission_params[:status]
    circuit = submission_params[:circuit]
    unless %w[unattempted attempted solved].include?(status)
      return render json: { error: "Invalid submission status" }, status: :unprocessable_entity
    end

    current_user.submission_history ||= []
    current_user.submission_history.delete_if { |submission| submission["question_id"] == question_id }
    current_user.submission_history << { "question_id" => question_id, "status" => status, "circuit" => circuit }

    if current_user.save
      render json: { message: "Submission posted successfully" }, status: :ok
    else
      render json: { error: "Failed to post submission" }, status: :unprocessable_entity
    end
  end

  def show_submission
    question_id = params[:question_id].to_i
    submission = current_user.submission_history.find { |sub| sub["question_id"] == question_id }
    if submission
      render json: submission, status: :ok
    else
      render json: { error: "Submission not found" }, status: :not_found
    end
  end
end
