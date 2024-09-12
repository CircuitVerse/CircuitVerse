# frozen_string_literal: true

FactoryBot.define do
  factory :question_submission_history do
    user { nil }
    question { nil }
    circuit_boilerplate { "" }
    status { "MyString" }
  end
end
