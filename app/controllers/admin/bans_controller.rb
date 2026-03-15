# frozen_string_literal: true

module Admin
  class BansController < BaseController
    before_action :set_user

    def ban
      if ban_params[:reason].blank?
        flash[:alert] = t(".ban_reason_required")
        return redirect_back(fallback_location: admin_reports_path)
      end

      if @user == current_user
        flash[:alert] = t(".cannot_ban_yourself")
      elsif @user.ban!(admin: current_user, reason: ban_params[:reason], report: find_report)
        flash[:notice] = t(".ban_success", name: @user.name)
        close_all_reports_for_user
      else
        flash[:alert] = t(".ban_failed")
      end

      redirect_back(fallback_location: admin_reports_path)
    end

    def unban
      if @user.unban!(admin: current_user)
        flash[:notice] = t(".unban_success", name: @user.name)
      else
        flash[:alert] = t(".unban_failed")
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
        return nil if params[:report_id].blank?

        Report.find_by(id: params[:report_id], reported_user_id: @user.id)
      end

      # Per maintainer: close ALL open reports for the user when banned
      def close_all_reports_for_user
        # rubocop:disable Rails/SkipsModelValidations
        Report.where(reported_user_id: @user.id, status: "open")
              .update_all(status: "action_taken", updated_at: Time.current)
        # rubocop:enable Rails/SkipsModelValidations
      end
  end
end
