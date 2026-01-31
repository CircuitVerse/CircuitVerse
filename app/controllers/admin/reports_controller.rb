# frozen_string_literal: true

module Admin
  class ReportsController < BaseController
    def index
      @reports = Report
                 .includes(:reporter, :reported_user)
                 .order(created_at: :desc)

      # Filter by status (open / action_taken)
      @reports = @reports.where(status: params[:status]) if params[:status].present?

      # Filter banned users
      return if params[:banned].blank?

      @reports = @reports
                 .joins(:reported_user)
                 .where(users: { banned: true })
    end
  end
end
