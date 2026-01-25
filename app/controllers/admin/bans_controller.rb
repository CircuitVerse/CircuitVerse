# frozen_string_literal: true

module Admin
  class BansController < BaseController
    before_action :set_user

    def ban
      unless ban_params[:reason].present?
        flash[:alert] = "Ban reason is required."
        return redirect_back(fallback_location: admin_reports_path)
      end

      if @user.admin?
        flash[:alert] = "Cannot ban admin users."
      elsif @user == current_user
        flash[:alert] = "Cannot ban yourself."
      elsif @user.ban!(admin: current_user, reason: ban_params[:reason], report: find_report)
        flash[:notice] = "User #{@user.name} has been banned."
        update_report_status if params[:report_id].present?
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
      Report.find_by(id: params[:report_id]) if params[:report_id].present?
    rescue NameError
      # Report model not yet implemented
      nil
    end

    def update_report_status
      report = find_report
      report&.update(status: 'action_taken')
    end
  end
end
