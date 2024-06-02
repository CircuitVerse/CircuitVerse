class Api::V1::QuestionsController < ApplicationController
    before_action :authenticate_user!
    before_action :authorize_moderator, only: [:create, :update, :destroy]
    before_action :set_question, only: [:update, :destroy]

    # POST /api/v1/questions
    def create
      @question = Question.new(question_params)
      if @question.save
        render json: @question, status: :created
      else
        render json: @question.errors, status: :unprocessable_entity
      end
    end

    # PUT /api/v1/questions/:id
    def update
      if @question.update(question_params)
        render json: @question, status: :ok
      else
        render json: @question.errors, status: :unprocessable_entity
      end
    end

    # DELETE /api/v1/questions/:id
    def destroy
      @question.destroy
      head :no_content
    end

    private

    def authorize_moderator
      unless current_user.question_bank_moderator?
        render json: { error: 'Unauthorized' }, status: :unauthorized
      end
    end

    def set_question
      @question = Question.find(params[:id])
    end

    def question_params
      params.require(:question).permit(:heading, :statement, :category_id, :difficulty_level_id, test_data:{}, circuit_boilerplate:{})
    end
end
