FactoryBot.define do
  factory :project do
    association :author, factory: :user
    project_access_type { "Private" }
    description { Faker::Lorem.sentence }
    data { Faker::Lorem.sentence }
    factory :project1 do
      association :author, factory: :user
      name {"Full Adder using basic gates"}
      project_access_type { "Public" }
      description { Faker::Lorem.sentence }
      data { Faker::Lorem.sentence }
    end
    factory :project2 do
      association :author, factory: :user
      name {"basic gates"}
      project_access_type { "Public" }
      description { Faker::Lorem.sentence }
      data { Faker::Lorem.sentence }
    end
    factory :project3 do
      association :author, factory: :user
      name {"Half Adder using basic gates"}
      project_access_type { "Public" }
      description { Faker::Lorem.sentence }
      data { Faker::Lorem.sentence }
    end
    factory :project4 do
      association :author, factory: :user
      name {"And Gate"}
      project_access_type { "Public" }
      description { Faker::Lorem.sentence }
      data { Faker::Lorem.sentence }
    end
  end
end
