# frozen_string_literal: true

module Admin
  class ReportsController < BaseController
    def index
      @reports = Report
                 .preload(:reporter, reported_user: :user_bans)
                 .order(created_at: :desc)

      # Filter by status (open / action_taken)
      @reports = @reports.where(status: params[:status]) if params[:status].present?

      # Filter banned users
      if params[:banned].present? && ActiveModel::Type::Boolean.new.cast(params[:banned])
        @reports = @reports
                   .joins(:reported_user)
                   .where(users: { banned: true })
      end

      @reports = @reports.paginate(page: params[:page], per_page: 25)
    end
  end
end
