# frozen_string_literal: true

FactoryBot.define do
  factory :submission do
    association :contest
    association :project
    association :user

    trait :with_private_project do
      project { association :project, project_access_type: "Private" }
    end
  end
end
