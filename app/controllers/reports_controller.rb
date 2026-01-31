# frozen_string_literal: true

class ReportsController < ApplicationController
  before_action :authenticate_user!

  def new
    @reported_user = User.find_by(id: params[:reported_user_id])

    unless @reported_user
      redirect_to root_path, alert: t("reports.user_not_found")
      return
    end

    if @reported_user == current_user
      redirect_to root_path, alert: t("reports.cannot_report_self")
      return
    end

    @report = Report.new(reported_user: @reported_user)
  end

  def create
    @report = Report.new(report_params)
    @report.reporter = current_user

    if @report.save
      redirect_to root_path, notice: t("reports.submitted")
    else
      @reported_user = @report.reported_user
      render :new, status: :unprocessable_entity
    end
  end

  private

    def report_params
      params.expect(report: %i[reported_user_id reason description])
    end
end
