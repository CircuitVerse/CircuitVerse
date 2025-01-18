# frozen_string_literal: true

FactoryBot.define do
  factory :project do
    name { Faker::Name.name }
    author { association :user }
    project_access_type { "Private" }
    description { Faker::Lorem.sentence }
  end
end
