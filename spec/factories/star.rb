# frozen_string_literal: true

FactoryBot.define do
  factory :star do
    association :user
    association :project

    created_at { Time.current }
    updated_at { created_at }
  end
end
