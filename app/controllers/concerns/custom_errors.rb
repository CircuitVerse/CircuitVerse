# frozen_string_literal: true

module CustomErrors
  extend ActiveSupport::Concern

  class InvalidOAuthToken < StandardError; end

  class UnsupportedOAuthProvider < StandardError; end
end
