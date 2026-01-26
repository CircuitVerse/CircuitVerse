# frozen_string_literal: true

FactoryBot.define do
  factory :report do
    association :reporter, factory: :user
    association :reported_user, factory: :user
    reason { "Violation of community guidelines" }
    description { "User posted inappropriate content" }
    status { "open" }

    trait :reviewed do
      status { "reviewed" }
    end

    trait :action_taken do
      status { "action_taken" }
    end

    trait :dismissed do
      status { "dismissed" }
    end
  end
end
