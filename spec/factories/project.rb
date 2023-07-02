# frozen_string_literal: true

FactoryBot.define do
  factory :project do
    name { Faker.name }
    association :author, factory: :user
    project_access_type { "Private" }
    description { Faker::Lorem.sentence }
    after(:build) do |project|
      project.image_preview.attach(
        io: File.open(Rails.root.join("spec/fixtures/files/default.png")),
        filename: "default.png",
        content_type: "image/png"
      )
    end
  end
end
