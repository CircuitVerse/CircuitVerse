# frozen_string_literal: true

FactoryBot.define do
  factory :announcement do
    body { "MyText" }
    link { "MyText" }
    start_date { "2020-10-21 15:38:24" }
    end_date { "2020-10-21 15:38:24" }
  end
end
