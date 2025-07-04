# frozen_string_literal: true

FactoryBot.define do
  factory :contest_winner do
    association :contest
    association :submission
    association :project, factory: :project
  end
end
