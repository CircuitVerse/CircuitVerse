# frozen_string_literal: true

class ReportsController < ApplicationController
  before_action :authenticate_user!

  def new
    @reported_user = User.find_by(id: params[:reported_user_id])

    unless @reported_user
      redirect_to root_path, alert: "Reported user must exist"
      return
    end

    @report = Report.new(reported_user: @reported_user)
  end

  def create
    @report = Report.new(report_params)
    @report.reporter = current_user

    if @report.save
      redirect_to root_path, notice: "Report submitted successfully"
    else
      @reported_user = @report.reported_user
      render :new, status: :unprocessable_entity
    end
  end

  private

  def report_params
    params.require(:report).permit(
      :reported_user_id,
      :reason,
      :description
    )
  end
end

