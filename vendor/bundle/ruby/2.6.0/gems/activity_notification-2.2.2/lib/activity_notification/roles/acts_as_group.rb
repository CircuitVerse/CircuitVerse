module ActivityNotification
  # Manages to add all required configurations to group models of notification.
  module ActsAsGroup
    extend ActiveSupport::Concern

    class_methods do
      # Adds required configurations to group models.
      #
      # == Parameters:
      # * :printable_name or :printable_notification_group_name
      #   * Printable notification group name.
      #     This parameter is a optional since `ActivityNotification::Common.printable_name` is used as default value.
      #     :printable_name is the same option as :printable_notification_group_name
      # @example Define printable name with article title
      #   # app/models/article.rb
      #   class Article < ActiveRecord::Base
      #     acts_as_notification_group printable_name: ->(article) { "article \"#{article.title}\"" }
      #   end
      #
      # @param [Hash] options Options for notifier model configuration
      # @option options [Symbol, Proc, String]  :printable_name  (ActivityNotification::Common.printable_name) Printable notifier target name
      # @return [Hash] Configured parameters as notifier model
      def acts_as_group(options = {})
        include Group

        options[:printable_notification_group_name] ||= options.delete(:printable_name)
        set_acts_as_parameters([:printable_notification_group_name], options)
      end
      alias_method :acts_as_notification_group, :acts_as_group

      # Returns array of available notification group options in acts_as_group.
      # @return [Array<Symbol>] Array of available notification group options
      def available_group_options
        [:printable_notification_group_name, :printable_name].freeze
      end
    end
  end
end
