# frozen_string_literal: true

FactoryBot.define do
  factory :question do
    heading { "Sample Heading" }
    statement { "Sample Statement" }
    difficulty_level { "easy" }
    qid { "sample-qid" }
    test_data { "Sample Test Data" }
    circuit_boilerplate { "Sample Circuit Boilerplate" }
    association :category, factory: :question_category
  end
end
