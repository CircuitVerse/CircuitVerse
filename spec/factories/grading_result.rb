# frozen_string_literal: true

FactoryBot.define do
  factory :grading_result do
    association :project
    suite_snapshot { { "type" => "comb", "groups" => [] } }
    breakdown { [] }
  end
end
