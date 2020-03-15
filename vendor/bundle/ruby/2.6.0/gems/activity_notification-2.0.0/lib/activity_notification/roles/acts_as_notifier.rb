module ActivityNotification
  # Manages to add all required configurations to notifier models of notification.
  module ActsAsNotifier
    extend ActiveSupport::Concern

    class_methods do
      # Adds required configurations to notifier models.
      #
      # == Parameters:
      # * :printable_name or :printable_notifier_name
      #   * Printable notifier name.
      #     This parameter is a optional since `ActivityNotification::Common.printable_name` is used as default value.
      #     :printable_name is the same option as :printable_notifier_name
      # @example Define printable name with user name of name field
      #   # app/models/user.rb
      #   class User < ActiveRecord::Base
      #     acts_as_notifier printable_name: :name
      #   end
      #
      # @param [Hash] options Options for notifier model configuration
      # @option options [Symbol, Proc, String]  :printable_name  (ActivityNotification::Common.printable_name) Printable notifier target name
      # @return [Hash] Configured parameters as notifier model
      def acts_as_notifier(options = {})
        include Notifier

        options[:printable_notifier_name] ||= options.delete(:printable_name)
        set_acts_as_parameters([:printable_notifier_name], options)
      end

      # Returns array of available notifier options in acts_as_notifier.
      # @return [Array<Symbol>] Array of available notifier options
      def available_notifier_options
        [:printable_notifier_name, :printable_name].freeze
      end
    end
  end
end
