# frozen_string_literal: true

module DatabaseConsistency
  module Errors
    # The base error class
    class Base < StandardError; end

    # The error class for missing field
    class MissingField < Base; end
  end
end
