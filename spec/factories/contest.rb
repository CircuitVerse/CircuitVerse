# frozen_string_literal: true

FactoryBot.define do
  factory :contest do
    deadline { Faker::Date.forward(days: 7) }
  end
end
