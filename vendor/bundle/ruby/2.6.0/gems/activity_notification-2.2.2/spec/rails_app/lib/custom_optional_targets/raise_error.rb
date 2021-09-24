module CustomOptionalTarget
  # Optional target implementation to raise error.
  class RaiseError < ActivityNotification::OptionalTarget::Base
    def initialize_target(options = {})
      @raise_error = options[:raise_error] == false ? false : true
    end

    def notify(notification, options = {})
      if @raise_error
        raise 'Intentional RuntimeError in CustomOptionalTarget::RaiseError'
      end
    end
  end
end