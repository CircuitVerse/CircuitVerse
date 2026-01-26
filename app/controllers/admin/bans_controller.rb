# frozen_string_literal: true

module Admin
  class BansController < BaseController
    before_action :set_user

    def ban
      unless ban_params[:reason].present?
        flash[:alert] = "Ban reason is required."
        return redirect_back(fallback_location: admin_reports_path)
      end

      if @user == current_user
        flash[:alert] = "Cannot ban yourself."
      elsif @user.ban!(admin: current_user, reason: ban_params[:reason], report: find_report)
        flash[:notice] = "User #{@user.name} has been banned."
        close_all_reports_for_user
      else
        flash[:alert] = "Failed to ban user."
      end
      
      redirect_back(fallback_location: admin_reports_path)
    end

    def unban
      if @user.unban!(admin: current_user)
        flash[:notice] = "User #{@user.name} has been unbanned."
      else
        flash[:alert] = "Failed to unban user."
      end
      
      redirect_back(fallback_location: admin_reports_path)
    end

    private

    def set_user
      @user = User.find(params[:id])
    end

    def ban_params
      params.permit(:reason, :report_id)
    end

    def find_report
      return nil unless params[:report_id].present?

      Report.find_by(id: params[:report_id], reported_user_id: @user.id)
    rescue NameError
      nil
    end

    # Per maintainer: close ALL open reports for the user when banned
    def close_all_reports_for_user
      Report.where(reported_user_id: @user.id, status: 'open')
            .update_all(status: 'action_taken')
    rescue NameError
      # Report model not available
    end
  end
end

