# frozen_string_literal: true

FactoryBot.define do
  factory :question do
    heading { "MyString" }
    statement { "MyText" }
    category { nil }
    difficulty_level { nil }
    test_data { "" }
    circuit_boilerplate { "" }
  end
end
