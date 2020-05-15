# frozen_string_literal: true

module CustomErrors
  extend ActiveSupport::Concern

  class UnauthenticatedError < StandardError; end

  class MissingAuthHeader < StandardError; end
end
