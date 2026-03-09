FactoryBot.define do
  factory :subgroup do
    name { "Test Subgroup" }
    association :group
  end
end
