# frozen_string_literal: true

FactoryBot.define do
  factory :subgroup do
    name { "Test Subgroup" }
    association :group
  end
end