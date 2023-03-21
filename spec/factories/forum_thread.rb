# frozen_string_literal: true

FactoryBot.define do
  factory :forum_thread do
    title { "Thread name" }
    slug { "rails" }
  end
end
