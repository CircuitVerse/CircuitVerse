# frozen_string_literal: true

FactoryBot.define do
  factory :project_datum, class: "ProjectDatum" do
    data { { name: "circuit data" }.to_json }
    project
  end
end
