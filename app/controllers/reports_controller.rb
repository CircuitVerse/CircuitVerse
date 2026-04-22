# frozen_string_literal: true

class ReportsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_and_validate_reported_user

  def new
    @report = Report.new(reported_user: @reported_user)
  end

  def create
    @report = Report.new(report_params)
    @report.reporter = current_user
    @report.reported_user = @reported_user

    if @report.save
      redirect_to root_path, notice: t("reports.submitted")
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

    def set_and_validate_reported_user
      @reported_user = User.find_by(id: params[:reported_user_id].presence || report_params_user_id)

      unless @reported_user
        redirect_to root_path, alert: t("reports.user_not_found")
        return
      end

      return unless @reported_user == current_user

      redirect_to root_path, alert: t("reports.cannot_report_self")
    end

    def report_params_user_id
      params.dig(:report, :reported_user_id)
    end

    def report_params
      params.expect(report: %i[reported_user_id reason description])
    end
end
