module CustomOptionalTarget
  # Optional target implementation to output console.
  class ConsoleOutput < ActivityNotification::OptionalTarget::Base
    def initialize_target(options = {})
      @console_out = options[:console_out] == false ? false : true
    end

    def notify(notification, options = {})
      if @console_out
        puts "----- Optional targets: #{self.class.name} -----"
        puts render_notification_message(notification, options)
        puts "-----------------------------------------------------------------"
      end
    end
  end
end