# frozen_string_literal: true

class ErrorsController < ApplicationController
  def not_found
    respond_to do |format|
      format.html { render status: :not_found }
      format.json { render json: { error: "Resource not found" }, status: :not_found }
    end
  end

  def unacceptable
    respond_to do |format|
      format.html { render status: :unprocessable_content }
      format.json { render json: { error: "Params unacceptable" }, status: :unprocessable_content }
    end
  end

  def internal_error
    respond_to do |format|
      format.html { render status: :internal_server_error }
      format.json do
        render json: { error: "Internal server error" }, status: :internal_server_error
      end
    end
  end
end
