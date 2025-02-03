# frozen_string_literal: true

FactoryBot.define do
  factory :project do
    name { Faker.name }
    association :author, factory: :user
    project_access_type { "Private" }
    description { Faker::Lorem.sentence }
  end
end
