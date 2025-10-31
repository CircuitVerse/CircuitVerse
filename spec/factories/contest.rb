
# frozen_string_literal: true

FactoryBot.define do
  factory :contest do
    sequence(:name) { |n| "Test Contest #{n}" } 
    deadline { 1.day.from_now }
    status   { :live }
  end
end