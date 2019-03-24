FactoryBot.define do
  factory :project do
    name { Faker.name }
    association :author, factory: :user
    project_access_type { "Private" }
    description { Faker::Lorem.sentence }
    data { Faker::Lorem.sentence }
  end
end
