# frozen_string_literal: true

class Api::V1::ThreadsController < Api::V1::BaseController
  before_action :authenticate_user!
  before_action :load_resource

  # PUT /api/v1/threads/:id/close
  def close
    if @commontator_thread.close(current_user)
      render json: { message: "thread closed" }
    else
      api_error(status: 409, errors: "thread is already closed")
    end
  end

  # PUT /api/v1/threads/:id/reopen
  def reopen
    if @commontator_thread.reopen
      render json: { message: "thread reopened" }
    else
      api_error(status: 409, errors: "thread is already opened")
    end
  end

  # PUT /api/v1/threads/:id/subscribe
  def subscribe
    security_transgression_unless @commontator_thread.can_subscribe?(current_user)

    if @commontator_thread.subscribe(current_user)
      render json: { message: "thread subscribed" }
    else
      api_error(status: 409, errors: "thread already subscribed")
    end
  end

  # PUT /api/v1/threads/:id/unsubscribe
  def unsubscribe
    security_transgression_unless @commontator_thread.can_subscribe?(current_user)

    if @commontator_thread.unsubscribe(current_user)
      render json: { message: "thread unsubscribed" }
    else
      api_error(status: 409, errors: "thread not subscribed")
    end
  end

  private

    def load_resource
      @commontator_thread = Commontator::Thread.find(params[:id])

      security_transgression_unless @commontator_thread.can_be_read_by? current_user
    end
end
