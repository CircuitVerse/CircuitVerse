module ActivityNotification
  # Module included in api controllers to select target
  module CommonApiController
    extend ActiveSupport::Concern

    included do
      rescue_from ActiveRecord::RecordNotFound,      with: :render_resource_not_found if defined?(ActiveRecord)
      rescue_from Mongoid::Errors::DocumentNotFound, with: :render_resource_not_found if ActivityNotification.config.orm == :mongoid
      rescue_from Dynamoid::Errors::RecordNotFound,  with: :render_resource_not_found if ActivityNotification.config.orm == :dynamoid
    end

    protected

      # Override to do nothing instead of JavaScript view for ajax request or redirects to back.
      # @api protected
      def return_back_or_ajax
      end

      # Override to do nothing instead of redirecting to notifiable_path
      # @api protected
      def redirect_to_notifiable_path
      end

      # Override to do nothing instead of redirecting to subscription path
      # @api protected
      def redirect_to_subscription_path
      end

  end
end
