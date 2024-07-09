# frozen_string_literal: true

class QuestionCategory < ApplicationRecord
  has_many :questions, dependent: :destroy
end

