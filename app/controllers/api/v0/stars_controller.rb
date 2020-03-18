module Api
  module V0

    class StarsController < ApplicationController
      before_action :set_star, only: [:show, :edit, :update, :destroy]
      before_action :authenticate_user!, only: [:edit, :update, :destroy, :create]

      def create
        @star = Star.new(star_params)
        @star.save
        render plain: "Star added!"
      end

      def destroy

        @star.destroy
        render plain: "Star removed!"
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
