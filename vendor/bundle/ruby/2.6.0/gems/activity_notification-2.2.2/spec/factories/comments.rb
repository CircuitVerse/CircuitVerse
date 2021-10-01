FactoryBot.define do
  factory :comment do
    article
    association :user, factory: :confirmed_user
  end
end
