# frozen_string_literal: true

FactoryBot.define do
  factory :user_ban do
    association :user
    association :admin, factory: %i[user admin]
    reason { "Violation of community guidelines" }
    lifted_at { nil }

    trait :lifted do
      lifted_at { Time.current }
      association :lifted_by, factory: %i[user admin]
    end

    trait :with_report do
      association :report
    end
  end
end
