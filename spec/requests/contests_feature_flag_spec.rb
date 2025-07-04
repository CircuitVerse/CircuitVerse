class ContestsController < ApplicationController
  before_action :authorize_admin!, only: [:admin_list]

  def admin_list
    # Your admin list logic here
    @contests = Contest.all
  end

  private

  def authorize_admin!
    unless current_user&.admin?
      respond_to do |format|
        format.html { redirect_to root_path, alert: "You are not authorized to do the requested operation" }
        format.json { head :forbidden }
      end
    end
  end
end
