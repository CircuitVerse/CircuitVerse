# frozen_string_literal: true

FactoryBot.define do
  factory :comment_thread do
    association :commontable, factory: :project
  end
end
