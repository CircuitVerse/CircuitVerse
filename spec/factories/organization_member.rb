# frozen_string_literal: true

FactoryBot.define do
  factory :organization_member do
    role { :member }
    association :organization
    association :user
  end
end
