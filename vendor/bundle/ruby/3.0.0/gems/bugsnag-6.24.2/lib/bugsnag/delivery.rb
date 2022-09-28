module Bugsnag
  module Delivery
    class << self
      ##
      # Add a delivery method to the list of supported methods. Any registered
      # method can then be used by name in Configuration.
      #
      # ```
      # require 'bugsnag'
      # Bugsnag::Delivery.register(:my_delivery_queue, MyDeliveryQueue)
      # Bugsnag.configure do |config|
      #   config.delivery_method = :my_delivery_queue
      # end
      # ```
      def register(name, delivery_method)
        delivery_methods[name.to_sym] = delivery_method
      end

      ##
      # Reference a delivery method by name
      def [](name)
        delivery_methods[name.to_sym]
      end

      private
      def delivery_methods
        @delivery_methods ||= {}
      end
    end
  end
end
