# frozen_string_literal: true

class Api::V1::FcmController < Api::V1::BaseController
  before_action :authenticate_user!

  # POST /api/v1/fcm/token
  def save_token
    # fetches or create FCM for current_user
    @token = Fcm.find_by(user_id: current_user.id)
    @token ||= Fcm.new(user_id: current_user.id)
    @token.token = params[:token]

    if @token.save
      render json: { "message": "token saved" }
    else
      api_error(status: 422, errors: @token.errors)
    end
  end
end
