# frozen_string_literal: true

FactoryBot.define do
  factory :comment do
    association :thread, factory: :comment_thread
    association :creator, factory: :user
    body { Faker::Lorem.sentence }
  end
end
