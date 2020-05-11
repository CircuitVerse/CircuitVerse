module CustomErrors
  extend ActiveSupport::Concern

  class UnauthenticatedError < StandardError; end
end
