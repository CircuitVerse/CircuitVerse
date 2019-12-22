# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    email { Faker::Internet.email }
    password { Faker::Alphanumeric.alphanumeric number: 10 }
    name { Faker::Name.name }
    admin { false }
    profile_picture { File.open("public/img/test_profilepicture.PNG") }
  end
end
