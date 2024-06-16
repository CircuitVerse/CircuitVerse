# frozen_string_literal: true

class CategoriesController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_moderator, only: %i[create]

  def index
    @categories = Category.all
    render json: @categories
  end

  def create
    @category = Category.new(category_params)
    if @category.save
      render json: @category, status: :created
    else
      render json: @category.errors, status: :unprocessable_entity
    end
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
