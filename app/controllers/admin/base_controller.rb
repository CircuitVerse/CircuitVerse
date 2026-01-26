# frozen_string_literal: true

module Admin
  class BaseController < ApplicationController
    before_action :authenticate_user!
    before_action :require_admin!

    private

      def require_admin!
        return if current_user&.admin?

        flash[:alert] = "Access denied. Admin privileges required."
        redirect_to root_path
      end
  end
end
