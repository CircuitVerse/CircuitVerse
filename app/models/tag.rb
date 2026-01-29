# frozen_string_literal: true

class Tag < ApplicationRecord
  has_many :taggings
  has_many :projects, through: :taggings

  validates :name, presence: true, length: { minimum: 1 }, uniqueness: { case_sensitive: false }
end
