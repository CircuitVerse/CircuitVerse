# frozen_string_literal: true

FactoryBot.define do
  factory :star do
    association :user
    association :project
  end
end
