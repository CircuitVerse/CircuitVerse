# frozen_string_literal: true

module CustomErrors
  extend ActiveSupport::Concern

  class UnauthenticatedError < StandardError; end

  class MissingAuthHeader < StandardError; end

  class InvalidOAuthToken < StandardError; end

  class UnsupportedOAuthProvider < StandardError; end
end
