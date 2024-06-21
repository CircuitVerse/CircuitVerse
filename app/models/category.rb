# frozen_string_literal: true

class Category < ApplicationRecord
  has_many :questions, dependent: :destroy
end
