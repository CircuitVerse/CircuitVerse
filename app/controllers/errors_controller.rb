# frozen_string_literal: true

class ErrorsController < ApplicationController
  def not_found
    respond_to do |format|
      format.html { render status: :not_found }
      format.json { render json: { error: t("errors.not_found.json_no_resource_msg") }, status: :not_found }
    end
  end

  def unacceptable
    respond_to do |format|
      format.html { render status: :unprocessable_entity }
      format.json { render json: { error: t("errors.unacceptable.json_invalid_param_msg") }, status: :unprocessable_entity }
    end
  end

  def internal_error
    respond_to do |format|
      format.html { render status: :internal_server_error }
      format.json { render json: { error: t("errors.internal_error.json_internal_error_msg") }, status: :internal_server_error }
    end
  end
end
