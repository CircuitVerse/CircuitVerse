# frozen_string_literal: true

module Admin
  class ReportsController < BaseController
    def index
      @reports = Report.includes(:reporter, :reported_user)
                       .order(created_at: :desc)
      
      # Filtering
      @reports = @reports.where(status: params[:status]) if params[:status].present?
      @reports = @reports.joins(:reported_user).where(users: { banned: true }) if params[:show_banned] == '1'
      
      # Pagination can be added later if needed
      # @reports = @reports.page(params[:page]).per(25)
    end
  end
end

