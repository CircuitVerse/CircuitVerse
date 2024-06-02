# frozen_string_literal: true

class Api::V1::DifficultyLevelsController < ApplicationController 
    before_action :authenticate_user!
    # GET /api/v1/difficulty_levels
    def index
        @difficulty_levels = DifficultyLevel.all
        render json: @difficulty_levels
    end

    # POST /api/v1/difficulty_levels
    def create
        @difficulty_level = DifficultyLevel.new(difficulty_level_params)
    
        if @difficulty_level.save
          render json: @difficulty_level, status: :created
        else
          render json: @difficulty_level.errors, status: :unprocessable_entity
        end
      end


    private

    def difficulty_level_params
      params.require(:difficulty_level).permit(:name, :value)
    end

end
