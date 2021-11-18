if defined?(ActionCable)
  # Action Cable API channel to subscribe broadcasted notifications.
  class ActivityNotification::NotificationApiChannel < ActivityNotification::NotificationChannel
    # ActionCable::Channel::Base#subscribed
    # @see https://api.rubyonrails.org/classes/ActionCable/Channel/Base.html#method-i-subscribed
    def subscribed
      stream_from "#{ActivityNotification.config.notification_api_channel_prefix}_#{@target.to_class_name}#{ActivityNotification.config.composite_key_delimiter}#{@target.id}"
    rescue
      reject
    end
  end
end
