module Lookbook
  module NavigableEntity
    extend ActiveSupport::Concern

    included do
      # @!group Visibility

      # Whether or not the entity is hidden (i.e. hidden from navigation)
      #
      # @return [Boolean] true if hidden
      def hidden?
        fetch_config(:hidden, false)
      end

      # Whether or not the entity is visible (i.e. present in navigation)
      #
      # @return [Boolean] true if visible
      def visible?
        !hidden?
      end

      # @!endgroup

      # @api private
      def priority
        return @_priority if @_priority

        pos = if @priority_prefixes && respond_to?(:file_name)
          PriorityPrefixParser.call(file_name).first || fetch_config(:priority, default_priority)
        else
          fetch_config(:priority, default_priority)
        end

        @_priority ||= @_fallback_priority || pos.to_i
      end

      # @api private
      def default_priority=(i)
        @default_priority = i.to_i
      end

      # @api private
      def depth
        lookup_path.split("/").size
      end

      # @api private
      def default_priority
        @default_priority || 10000
      end

      # @api private
      def <=>(other)
        if respond_to?(:sort_handler, true)
          sort_handler(other)
        else
          [priority, label] <=> [other.priority, other.label]
        end
      end
    end
  end
end
