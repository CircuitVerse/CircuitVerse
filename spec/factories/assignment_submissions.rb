# frozen_string_literal: true

FactoryBot.define do
  factory :assignment_submission do
    status       { :draft }
    submitted_at { Time.zone.now }
    association :assignment
    association :project
    association :user
  end
end
