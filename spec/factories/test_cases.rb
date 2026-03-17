FactoryBot.define do
  factory :test_case do
    assignment { nil }
    input { "MyText" }
    expected_output { "MyText" }
    description { "MyString" }
  end
end
