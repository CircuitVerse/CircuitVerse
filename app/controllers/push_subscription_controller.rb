# frozen_string_literal: true

class PushSubscriptionController < ApplicationController
  before_action :authenticate_user!, only: %i[create test]
  skip_before_action :verify_authenticity_token, only: %i[create test]

  # POST /push/subscription/new
  def create
    is_subscribed = PushSubscription.find_by(auth: params[:keys][:auth])
    if !is_subscribed
      @subscription = current_user.push_subscriptions.new(
        endpoint: params[:endpoint],
        auth: params[:keys][:auth],
        p256dh: params[:keys][:p256dh]
      )
      if @subscription.save
        render json: {
          status: "ok"
        }, status: :created
      else
        render json: @subscription.errors, status: :unprocessable_entity
      end
    end
  end

  # POST /push/test
  def test
    current_user.send_push_notification(push_test_params[:message])
  end

  private

    def push_subscription_params
      params.require(:push_subscription).permit(:endpoint, :auth, :p256dh)
    end

    def push_test_params
      params.require(:push).permit(:message)
    end
end
