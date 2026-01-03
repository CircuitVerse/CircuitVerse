class Commontator::ApplicationController < ActionController::Base
  before_action :commontator_set_user, :ensure_user

  rescue_from Commontator::SecurityTransgression, with: -> { head(:forbidden) }

  helper Commontator::ApplicationHelper

  protected

  def security_transgression_unless(check)
    raise Commontator::SecurityTransgression unless check
  end

  def ensure_user
    security_transgression_unless(@commontator_user && @commontator_user.is_commontator)
  end

  def set_thread
    @commontator_thread = params[:thread_id].blank? ?
      Commontator::Thread.find(params[:id]) :
      Commontator::Thread.find(params[:thread_id])

    security_transgression_unless @commontator_thread.can_be_read_by? @commontator_user
  end

  def commontable_url
    main_app.polymorphic_url(@commontator_thread.commontable)
  end
end
