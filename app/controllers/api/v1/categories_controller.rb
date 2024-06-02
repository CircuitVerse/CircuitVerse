class Api::V1::CategoriesController < ApplicationController 
    before_action :authenticate_user!
    # GET /api/v1/categories
    def index
        @categories = Category.all
        render json: @categories
      end

      # POST /api/v1/categories
    def create
        @category = Category.new(category_params)
        if @category.save
          render json: @category, status: :created
        else
          render json: @category.errors, status: :unprocessable_entity
        end
      end

      private

      # Strong parameters for category
    def category_params
        params.require(:category).permit(:name)
    end

end
