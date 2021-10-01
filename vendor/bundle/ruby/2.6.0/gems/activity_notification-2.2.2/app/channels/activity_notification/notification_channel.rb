if defined?(ActionCable)
  # Action Cable channel to subscribe broadcasted notifications.
  class ActivityNotification::NotificationChannel < ActivityNotification.config.parent_channel.constantize
    before_subscribe :set_target
    before_subscribe :authenticate_target!

    # ActionCable::Channel::Base#subscribed
    # @see https://api.rubyonrails.org/classes/ActionCable/Channel/Base.html#method-i-subscribed
    def subscribed
      stream_from "#{ActivityNotification.config.notification_channel_prefix}_#{@target.to_class_name}#{ActivityNotification.config.composite_key_delimiter}#{@target.id}"
    rescue
      reject
    end

    protected

      # Sets @target instance variable from request parameters.
      # @api protected
      # @return [Object] Target instance (Reject subscription when request parameters are not enough)
      def set_target
        target_type = params[:target_type]
        target_class = target_type.to_s.to_model_class
        @target = params[:target_id].present? ?
          target_class.find_by!(id: params[:target_id]) :
          target_class.find_by!(id: params["#{target_type.to_s.to_resource_name[/([^\/]+)$/]}_id"])
        rescue
        reject
      end

      # Allow the target to subscribe notification channel if notification_action_cable_with_devise? returns false
      # @api protected
      # @return [Response] Returns connected or rejected
      def authenticate_target!
        reject if @target.nil? || @target.notification_action_cable_with_devise?
      end
  end
end
