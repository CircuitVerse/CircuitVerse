# frozen_string_literal: true

class ReportsController < ApplicationController
  before_action :authenticate_user!

  def new
    @report = Report.new
  end

  def create
    @report = Report.new(report_params)
    @report.reporter = current_user

    if @report.save
      redirect_to root_path, notice: t(".success")
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

    def report_params
      params.expect(report: %i[reported_user_id reason description])
    end
end
