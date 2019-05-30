# frozen_string_literal: true

FactoryBot.define do
  factory :pending_invitation do
    email { Faker::Internet.email }
  end
end
