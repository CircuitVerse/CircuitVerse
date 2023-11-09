# frozen_string_literal: true

FactoryBot.define do
  factory :circuit_element do
    name { Faker::Lorem.word }
    category do
      ["Input", "Output", "Gates", "Decoders & Plexers", "Sequential Elements",
       "Memory Elements", "Test Bench", "Misc"].sample
    end
  end
end
