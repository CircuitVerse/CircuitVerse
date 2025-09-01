# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "user#{n}@example.com" }

    password { "password123" }

    name   { Faker::Name.name }
    locale { "en" }
    admin  { false }

    trait :admin do
      admin { true }
    end

    trait :confirmed do
      confirmed_at { Time.current }
    end
  end
end
