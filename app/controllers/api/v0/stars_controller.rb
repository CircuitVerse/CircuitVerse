module Api
  module V0

    class StarsController < ApplicationController
      before_action :set_star, only: [:destroy]
      before_action :authenticate_user!, only: [:create, :destroy]

      def create
        @star = Star.new(star_params)
        @star.save!
        render :json => StarSerializer.new(@star).serialized_json
      end

      def destroy
        @star.destroy!
        render :json => {}, status: :no_content
      end

      private
        def set_star
          @star = Star.find(params[:id])
        end

        def star_params
          params.require(:star).permit(:user_id, :project_id)
        end
    end

  end
end
