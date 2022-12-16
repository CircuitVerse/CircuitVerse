module Mailkick
  class SubscriptionsController < ActionController::Base
    protect_from_forgery with: :exception

    before_action :set_email

    def show
    end

    def unsubscribe
      Mailkick.opt_out(@options)
      redirect_to subscription_path(params[:id])
    end

    def subscribe
      Mailkick.opt_in(@options)
      redirect_to subscription_path(params[:id])
    end

    protected

    def set_email
      @email, user_id, user_type, @list = Mailkick.message_verifier.verify(params[:id])
      if user_type
        # on the unprobabilistic chance user_type is compromised, not much damage
        @user = user_type.constantize.find(user_id)
      end
      @options = {
        email: @email,
        user: @user,
        list: @list
      }
    rescue ActiveSupport::MessageVerifier::InvalidSignature
      render plain: "Subscription not found", status: :bad_request
    end

    def opted_out?
      Mailkick.opted_out?(@options)
    end
    helper_method :opted_out?

    def subscribe_url
      subscribe_subscription_path(params[:id])
    end
    helper_method :subscribe_url

    def unsubscribe_url
      unsubscribe_subscription_path(params[:id])
    end
    helper_method :unsubscribe_url
  end
end
