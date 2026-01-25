# frozen_string_literal: true

FactoryBot.define do
  factory :user_ban do
    association :user
    association :admin, factory: [:user, :admin]
    reason { "Violation of community guidelines" }
    lifted_at { nil }

    trait :lifted do
      lifted_at { Time.current }
    end

    trait :with_report do
      # Will be implemented when Report model exists
      # association :report
    end
  end
end
