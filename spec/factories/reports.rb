# frozen_string_literal: true

FactoryBot.define do
  factory :report do
    reporter { nil }
    reported_user { nil }
    reason { "MyString" }
    description { "MyText" }
    status { "MyString" }
  end
end
