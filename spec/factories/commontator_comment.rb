# frozen_string_literal: true

FactoryBot.define do
  factory :commontator_comment, class: "Commontator::Comment" do
    creator_type { "User" }
    body { Faker::Lorem.sentence }
  end
end
