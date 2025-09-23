# frozen_string_literal: true

require "securerandom"

module Sentry
  module Utils
    DELIMITER = "-"

    def self.uuid
      SecureRandom.uuid.delete(DELIMITER)
    end
  end
end
