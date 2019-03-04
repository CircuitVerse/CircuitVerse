FactoryBot.define do
  factory :project do
    project_access_type { "Private" }
    description { Faker::Lorem.sentence }
    data { Faker::Lorem.sentence }
  end
end
