# frozen_string_literal: true

FactoryBot.define do
  factory :featured_circuit do
    association :project, factory: %i[project public]

    transient do
      offset_seconds { 0 }
    end

    after(:create) do |fc, evaluator|
      # rubocop:disable Rails/SkipsModelValidations
      fc.update_column(:created_at, fc.created_at + evaluator.offset_seconds) if evaluator.offset_seconds.to_i != 0
      # rubocop:enable Rails/SkipsModelValidations
    end
  end
end
