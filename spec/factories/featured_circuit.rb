# frozen_string_literal: true

FactoryBot.define do
  factory :featured_circuit do
    association :project, factory: %i[project public]
  end
end
