# frozen_string_literal: true

FactoryBot.define do
  factory :submission do
    contest
    project
    user   { project.author }
    winner { false }
  end
end
