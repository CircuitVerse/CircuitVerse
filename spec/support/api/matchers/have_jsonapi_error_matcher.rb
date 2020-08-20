# frozen_string_literal: true

RSpec::Matchers.define :have_jsonapi_error do |expected|
  match do |actual|
    return false if actual["errors"].empty?

    actual["errors"].any? do |error|
      return false unless error.key?("status") &&
                          error.key?("title") &&
                          error.key?("detail")

      [error["detail"], error["title"]].include? expected
    end
  end
end
