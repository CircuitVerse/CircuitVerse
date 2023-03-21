# frozen_string_literal: true

FactoryBot.define do
  factory :forum_post do
    body { Faker::Lorem.sentence }
  end
end
