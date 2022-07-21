# frozen_string_literal: true

FactoryBot.define do
  factory :notification do
    recipient { nil }
    type { "" }
    params { "" }
    read_at { "2022-07-21 10:12:22" }
  end
end
