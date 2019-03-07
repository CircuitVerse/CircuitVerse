FactoryBot.define do
  factory :assignment do
    deadline { Faker::Date.forward(23) }
  end
end
