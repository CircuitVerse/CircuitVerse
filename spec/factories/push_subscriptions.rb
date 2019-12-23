# frozen_string_literal: true

FactoryBot.define do
  factory :push_subscription do
    endpoint { "MyString" }
    p256dh { "MyString" }
    auth { "MyString" }
  end
end
