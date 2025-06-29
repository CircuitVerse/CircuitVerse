# frozen_string_literal: true

FactoryBot.define do
  factory :submission do
    association :contest
    association :project
    association :user
  end
end
