# frozen_string_literal: true

FactoryBot.define do
  factory :submission_vote do
    association :submission
    association :contest, factory: :contest
    association :user
  end
end
