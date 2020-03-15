FactoryBot.define do
  factory :user do
    email { Array.new(10){[*"A".."Z", *"0".."9"].sample}.join + '@example.com' }
    password { "password" }
    password_confirmation { "password" }
  end

  factory :confirmed_user, parent: :user do
    after(:build) { |user| user.skip_confirmation! }
  end
end
