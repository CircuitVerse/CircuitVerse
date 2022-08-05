# frozen_string_literal: true

FactoryBot.define do
  factory :noticed_notification do
    recipient { nil }
    type { "" }
    params { "" }
    read_at { "2022-08-05 10:56:28" }
  end
end
