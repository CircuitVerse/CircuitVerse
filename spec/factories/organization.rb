# frozen_string_literal: true

FactoryBot.define do
  factory :organization do
    sequence(:name) { |n| "Test Organization #{n}" }
    private { true }
  end
end
