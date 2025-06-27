# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    email { Faker::Internet.email }
    password { Faker::Alphanumeric.alphanumeric number: 10 }
    name { Faker::Name.name }
    locale { Faker::Config.locale }
    admin { false }
  end
end
