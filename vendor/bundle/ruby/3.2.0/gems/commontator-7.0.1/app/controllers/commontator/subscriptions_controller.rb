class Commontator::SubscriptionsController < Commontator::ApplicationController
  before_action :set_thread

  # PUT /threads/1/subscribe
  def subscribe
    security_transgression_unless @commontator_thread.can_subscribe?(@commontator_user)

    @commontator_thread.errors.add(:base, t('commontator.subscription.errors.already_subscribed')) \
      unless @commontator_thread.subscribe(@commontator_user)

    respond_to do |format|
      format.html { redirect_to commontable_url }
      format.js   { render :subscribe }
    end

  end

  # PUT /threads/1/unsubscribe
  def unsubscribe
    security_transgression_unless @commontator_thread.can_subscribe?(@commontator_user)

    @commontator_thread.errors.add(:base, t('commontator.subscription.errors.not_subscribed')) \
      unless @commontator_thread.unsubscribe(@commontator_user)

    respond_to do |format|
      format.html { redirect_to commontable_url }
      format.js   { render :subscribe }
    end
  end
end
