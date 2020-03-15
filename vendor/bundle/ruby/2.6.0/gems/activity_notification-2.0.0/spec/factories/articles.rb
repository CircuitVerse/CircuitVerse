FactoryBot.define do
  factory :article do
    association :user, factory: :confirmed_user
  end
end
