# frozen_string_literal: true

module Admin
  class ReportsController < BaseController
    def index
      @reports = Report
        .includes(:reporter, :reported_user)
        .order(created_at: :desc)

      # Filter by status (open / action_taken)
      if params[:status].present?
        @reports = @reports.where(status: params[:status])
      end

      # Filter banned users
      if params[:banned].present?
        @reports = @reports
          .joins(:reported_user)
          .where(users: { banned: true })
      end
    end
  end
end

