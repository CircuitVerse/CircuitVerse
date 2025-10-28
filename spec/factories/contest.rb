# frozen_string_literal: true

FactoryBot.define do
  factory :contest do
    deadline { 1.day.from_now }
    status   { :live }
  end
end
