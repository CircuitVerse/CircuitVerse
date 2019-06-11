# frozen_string_literal: true

class CircuitElement < ApplicationRecord
  has_and_belongs_to_many :assignments

  enum category: ["Input", "Output", "Gates", "Decoders & Plexers", "Sequential Elements",
    "Test Bench", "Misc"]

  mount_uploader :image, CircuitElementsImageUploader
end
