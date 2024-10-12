# frozen_string_literal: true

class QuestionCategoriesController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_moderator, only: %i[create destroy]

  def create
    param_name = params.require(:name)
    @category = QuestionCategory.new(name: param_name)
    @category.save
    redirect_to user_path(current_user.id), notice: "Category was successfully created."
  rescue ActionController::ParameterMissing
    redirect_to user_path(current_user.id), alert: "Missing category information."
  end

  def destroy
    @category = QuestionCategory.find(params[:id])
    @category.destroy
    redirect_to user_path(current_user.id), notice: "Category was successfully removed."
  end

  private

    def authorize_moderator
      authorize QuestionCategory.new, :question_bank_moderator?
    end
end
