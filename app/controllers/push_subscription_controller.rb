# frozen_string_literal: true

class PushSubscriptionController < ApplicationController
  before_action :authenticate_user!, only: %i[create test]
  skip_before_action :verify_authenticity_token, only: %i[create test]

  # POST /push/subscription/new
  def create
    @subscription = current_user.push_subscriptions.create(push_subscription_params)
    if @subscription.save
      render json: {
        status: "ok"
      }, status: :created
    else
      render json: @subscription.errors, status: :unprocessable_content
    end
  end

  # POST /push/test
  def test
    current_user.send_push_notification(push_test_params[:message])
  end

  private

    def push_subscription_params
      params.expect(push_subscription: %i[endpoint auth p256dh])
    end

    def push_test_params
      params.expect(push: [:message])
    end
end
