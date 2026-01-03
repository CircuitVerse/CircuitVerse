# frozen_string_literal: true

module Sentry
  module Utils
    module EnvHelper
      TRUTHY_ENV_VALUES = %w[t true yes y 1 on].freeze
      FALSY_ENV_VALUES = %w[f false no n 0 off].freeze

      def self.env_to_bool(value, strict: false)
        value = value.to_s
        normalized = value.downcase

        return false if FALSY_ENV_VALUES.include?(normalized)

        return true if TRUTHY_ENV_VALUES.include?(normalized)

        strict ? nil : !(value.nil? || value.empty?)
      end
    end
  end
end
