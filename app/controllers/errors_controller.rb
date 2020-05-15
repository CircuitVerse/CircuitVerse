# frozen_string_literal: true

class ErrorsController < ApplicationController
  def not_found
    respond_to do |format|
      format.html { render status: 404 }
      format.json { render json: { error: "Resource not found" }, status: 404 }
    end
  end

  def unacceptable
    respond_to do |format|
      format.html { render status: 422 }
      format.json { render json: { error: "Params unacceptable" }, status: 422 }
    end
  end

  def internal_error
    respond_to do |format|
      format.html { render status: 500 }
      format.json { render json: { error: "Internal server error" }, status: 500 }
    end
  end
  
  def bad_request
    respond_to do |format|
      format.html { render status: 400 }
      format.json { render json: { error: "Bad Request" }, status: 400  }
    end
  end

  def not_implemented
    respond_to do |format|
      format.html { render status: 501 }
      format.json { render json: { error: "Not Implemented" }, status: 501  }
    end
  end
end
