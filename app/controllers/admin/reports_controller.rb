# frozen_string_literal: true

module Admin
  class ReportsController < BaseController
    def index
      @reports = Report.includes(:reporter, :reported_user)
                       .order(created_at: :desc)
      
      # Filtering
      @reports = @reports.where(status: params[:status]) if params[:status].present?
      @reports = @reports.joins(:reported_user).where(users: { banned: true }) if params[:show_banned] == '1'
      
      # Pagination (if using kaminari)
      @reports = @reports.page(params[:page]).per(25) if defined?(Kaminari)
    rescue NameError => e
      # Report model not yet implemented by teammate
      flash.now[:alert] = "Report system not yet available. Please coordinate with teammate."
      @reports = []
    end
  end
end
