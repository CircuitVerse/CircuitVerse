module Lookbook
  module AnnotatableEntity
    extend ActiveSupport::Concern

    included do
      delegate :has_tag?, to: :code_object

      # @!group Annotations

      # Any notes added to the entity.
      # Returns the raw (unrendered) string which may contain markdown formatting.
      #
      # @return [String] The notes, or an empty string if none have been added
      def notes
        code_object.docstring.to_s.strip
      end

      # All tags that have been added to the entity.
      # Can be filtered by tag name by providing the name as an argument.
      #
      # @example :ruby
      #   all_tags = entity.tags
      #   display_tags = entity.tags(:display)
      #
      # @param name [Symbol] Optional tag type to filter by
      # @return [Array<YardTag>] Array of tags
      def tags(name = nil)
        code_object.tags(name)
      end

      # The first tag (optionally of a particular type)
      # added to the entity.
      #
      # @example :ruby
      #   first_tag = entity.tag
      #   first_display_tag = entity.tag(:display)
      #
      # @param name [Symbol] Optional tag type to filter by
      # @return [Array<YardTag>] Array of tags
      def tag(name = nil)
        tags(name).first
      end

      # @!endgroup

      protected

      attr_reader :code_object

      def fetch_config(key, fallback = nil, &block)
        value = case key.to_sym
        when :renders
          renders_config
        when :display_options
          display_options_config
        else
          tag(key).value if has_tag?(key)
        end

        Utils.value_or_fallback(value, fallback, &block)
      end

      private

      def renders_config
        return unless has_tag?(:component) || has_tag?(:renders)

        [*tags(:component), *tags(:renders)].map(&:value).compact
      end

      def display_options_config
        return unless has_tag?(:display)

        # Dynamic params set at the entity level are
        # not (yet?) supported so filter them out.
        display_tags = tags(:display).select do |tag|
          !tag.value.is_a?(Hash) && !tag.value.is_a?(Array)
        end

        display_tags.map { |tag| [tag.key.to_sym, tag.value] }.to_h
      end
    end
  end
end
