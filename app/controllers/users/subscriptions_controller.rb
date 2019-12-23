# frozen_string_literal: true

class Users::SubscriptionsController < ActivityNotification::SubscriptionsController
  before_action :authenticate_user!
  # GET /:target_type/:target_id/subscriptions
  # def index
  #   super
  # end

  # POST /:target_type/:target_id/subscriptions
  # def create
  #   super
  # end

  # GET /:target_type/:target_id/subscriptions/:id
  # def show
  #   super
  # end

  # DELETE /:target_type/:target_id/subscriptions/:id
  # def destroy
  #   super
  # end

  # POST /:target_type/:target_id/subscriptions/:id/subscribe
  # def subscribe
  #   super
  # end

  # POST /:target_type/:target_id/subscriptions/:id/unsubscribe
  # def unsubscribe
  #   super
  # end

  # POST /:target_type/:target_id/subscriptions/:id/subscribe_to_email
  # def subscribe_to_email
  #   super
  # end

  # POST /:target_type/:target_id/subscriptions/:id/unsubscribe_to_email
  # def unsubscribe_to_email
  #   super
  # end

  # protected

  # def set_target
  #   super
  # end

  # def set_subscription
  #   super
  # end

  # def subscription_params
  #   super
  # end

  # def set_index_options
  #   super
  # end

  # def load_index
  #   super
  # end

  # def controller_path
  #   super
  # end

  # def target_view_path
  #   super
  # end

  # def set_view_prefixes
  #   super
  # end

  # def return_back_or_ajax
  #   super
  # end
end
