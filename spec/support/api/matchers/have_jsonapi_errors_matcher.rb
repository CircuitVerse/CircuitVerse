# frozen_string_literal: true

RSpec::Matchers.define :have_jsonapi_errors do |expected|
  match do |actual|
    return false if actual["errors"].empty?
    actual["errors"].any? do |error|
      error.key?("status") &&
      error.key?("title") &&
      error.key?("detail")
    end
  end
end
