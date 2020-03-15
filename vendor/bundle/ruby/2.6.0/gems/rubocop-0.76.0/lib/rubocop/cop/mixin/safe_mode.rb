# frozen_string_literal: true

module RuboCop
  module Cop
    # Common functionality for Rails safe mode.
    #
    # This module can be removed from RuboCop 0.76.
    module SafeMode
      private

      def rails_safe_mode?
        safe_mode? || rails?
      end

      def safe_mode?
        cop_config['SafeMode']
      end

      def rails?
        config['Rails']&.fetch('Enabled')
      end
    end
  end
end
