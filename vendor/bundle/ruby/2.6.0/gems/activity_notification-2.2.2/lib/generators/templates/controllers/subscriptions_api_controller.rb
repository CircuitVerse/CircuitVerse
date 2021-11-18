class <%= @target_prefix %>SubscriptionsController < ActivityNotification::SubscriptionsController
  # GET /:target_type/:target_id/subscriptions
  # def index
  #   super
  # end

  # PUT /:target_type/:target_id/subscriptions
  # def create
  #   super
  # end

  # GET /:target_type/:target_id/subscriptions/find
  def find
    super
  end

  # GET /:target_type/:target_id/subscriptions/optional_target_names
  def optional_target_names
    super
  end

  # GET /:target_type/:target_id/subscriptions/:id
  # def show
  #   super
  # end

  # DELETE /:target_type/:target_id/subscriptions/:id
  # def destroy
  #   super
  # end

  # PUT /:target_type/:target_id/subscriptions/:id/subscribe
  # def subscribe
  #   super
  # end

  # PUT /:target_type/:target_id/subscriptions/:id/unsubscribe
  # def unsubscribe
  #   super
  # end

  # PUT /:target_type/:target_id/subscriptions/:id/subscribe_to_email
  # def subscribe_to_email
  #   super
  # end

  # PUT /:target_type/:target_id/subscriptions/:id/unsubscribe_to_email
  # def unsubscribe_to_email
  #   super
  # end

  # PUT /:target_type/:target_id/subscriptions/:id/subscribe_to_optional_target
  # def subscribe_to_optional_target
  #   super
  # end

  # PUT /:target_type/:target_id/subscriptions/:id/unsubscribe_to_optional_target
  # def unsubscribe_to_optional_target
  #   super
  # end
end