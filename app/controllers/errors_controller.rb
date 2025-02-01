# frozen_string_literal: true

class ErrorsController < ApplicationController
  def not_found
    Sentry.capture_message("Resource not found")
    respond_to do |format|
      format.html { render status: :not_found }
      format.json { render json: { error: "Resource not found" }, status: :not_found }
    end
  end

  def unacceptable
    Sentry.capture_message("Params unacceptable")
    respond_to do |format|
      format.html { render status: :unprocessable_entity }
      format.json { render json: { error: "Params unacceptable" }, status: :unprocessable_entity }
    end
  end

  def internal_error
    Sentry.capture_message("Internal server error")
    respond_to do |format|
      format.html { render status: :internal_server_error }
      format.json do
        render json: { error: "Internal server error" }, status: :internal_server_error
      end
    end
  end
end
