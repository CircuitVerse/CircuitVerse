# frozen_string_literal: true

class PushSubscriptionController < ApplicationController
  skip_after_action :verify_authorized

  before_action :authenticate_user!, only: %i[create test]
  skip_before_action :verify_authenticity_token, only: %i[create test]

  # POST /push/subscription/new
  def create
    attrs = push_subscription_params
    subscription = current_user.push_subscriptions.find_or_initialize_by(endpoint: attrs[:endpoint])
    subscription.assign_attributes(auth: attrs[:auth], p256dh: attrs[:p256dh])

    if subscription.save
      render json: {
        status: "ok"
      }, status: :created
    else
      render json: subscription.errors, status: :unprocessable_content
    end
  end

  # POST /push/test
  def test
    current_user.push_subscriptions.find_each do |subscription|
      subscription.send_push_notification(push_test_params[:message])
    end
    head :no_content
  end

  private

    def push_subscription_params
      params.expect(push_subscription: %i[endpoint auth p256dh])
    end

    def push_test_params
      params.expect(push: [:message])
    end
end
