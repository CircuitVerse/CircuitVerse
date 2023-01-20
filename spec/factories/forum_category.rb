# frozen_string_literal: true

FactoryBot.define do
  factory :forum_category do
    name { Faker::Lorem.word }
    slug { Faker::Lorem.word }
    color { "blue" }
  end
end
