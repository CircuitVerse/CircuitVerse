# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    email { Faker::Internet.email }
    password { Faker::Alphanumeric.alphanumeric(number: 10) }
    name { Faker::Name.name }
    locale { Faker::Config.locale }
    admin { false }

    trait :with_submission_history do
      after(:build) do |user|
        user.submission_history = {
          submissions: [
            {
              id: SecureRandom.uuid,
              score: 95.0
            }
          ]
        }
      end
    end

    trait :as_public do
      public { true }
    end

    trait :as_question_bank_moderator do
      question_bank_moderator { false }
    end
  end
end
