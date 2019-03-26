FactoryBot.define do
  factory :assignment do
    name { Faker::Lorem.word }
    deadline { Faker::Date.forward(23) }
    description { Faker::Lorem.sentence }
  end
end
