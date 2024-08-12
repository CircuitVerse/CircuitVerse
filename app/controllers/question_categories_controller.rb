# frozen_string_literal: true

class QuestionCategoriesController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_moderator, only: %i[create]

  def index
    @categories = QuestionCategory.all
    render json: @categories
  end

  def create
    @category = QuestionCategory.new(category_params)
    return unless @category.save

    render json: @category, status: :created
  end

  private

    def authorize_moderator
      return if current_user.question_bank_moderator?

      render json: { error: "Unauthorized" }, status: :unauthorized
    end

    def category_params
      params.require(:category).permit(:name)
    end
end
