# frozen_string_literal: true

FactoryBot.define do
  factory :project_datum do
    project
    data { "MyText" }
  end
end
