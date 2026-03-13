# frozen_string_literal: true

FactoryBot.define do
  factory :assignment do
    name { Faker::Lorem.word.gsub(/[^a-zA-Z\s]/, "") }
    deadline { Faker::Date.forward(days: 23) }
    description { Faker::Lorem.sentence }
    grades_finalized { false }
  end
end
