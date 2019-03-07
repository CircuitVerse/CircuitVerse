FactoryBot.define do
  factory :project do
    association :author, factory: :user
    name {Faker::name}
    project_access_type {"Public"}
    description {Faker::Lorem.sentence}
    data {Faker::Lorem.sentence}
  end
end
