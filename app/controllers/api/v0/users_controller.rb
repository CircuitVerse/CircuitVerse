module Api
  module V0

    class UsersController < ApplicationController

      before_action :authorize_request

      skip_before_action :verify_authenticity_token

      def index
        render :json => UserSerializer.new(@current_user).serialized_json
      end

      def update
        @current_user.update(user_params)
        if @current_user.update(user_params)
          render :json => UserSerializer.new(@current_user), status: :ok
        else
          render :json => @current_user.errors, status: :unprocessable_entity
        end
      end

      private

        def user_params
          params.require(:user).permit(:name, :educational_institute, :country, :subscribed)
        end

    end

  end
end

