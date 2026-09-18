# frozen_string_literal: true

FactoryBot.define do
  factory :comment_thread do
    association :commentable, factory: :project

    trait :closed do
      closed_at { Time.current }
      association :closer, factory: :user
    end
  end

  factory :comment do
    association :comment_thread
    association :user
    body { "A comment body" }

    trait :deleted do
      deleted_at { Time.current }
    end
  end
end
