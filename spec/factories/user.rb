# frozen_string_literal: true
include ActionDispatch::TestProcess

FactoryBot.define do
  factory :user do
    email { Faker::Internet.email }
    password { Faker::Alphanumeric.alphanumeric number: 10 }
    name { Faker::Name.name }
    admin { false }
    profile_picture { fixture_file_upload(Rails.root.join('spec', 'assets', 'test_profilepicture.png'), 'image/png') }
  end
end
