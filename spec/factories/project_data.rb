# frozen_string_literal: true

FactoryBot.define do
  factory :project_datum, class: "ProjectDatum" do
    data { { name: "circuit data" } }
    project
  end
end
