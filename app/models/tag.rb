# frozen_string_literal: true

class Tag < ApplicationRecord
  has_many :taggings, dependent: :destroy
  has_many :projects, through: :taggings

  normalizes :name, with: ->(name) { name.to_s.strip }

  validates :name, presence: true
  validates :name, length: { minimum: 1 }
  validates :name, uniqueness: { case_sensitive: false }

  scope :with_name_insensitive, ->(name) { where("LOWER(name) = ?", name.to_s.strip.downcase) }

  def self.named(name)
    with_name_insensitive(name).first
  end

  def self.find_or_create_with_name!(name)
    normalized = name.to_s.strip
    named(normalized) || create!(name: normalized)
  rescue ActiveRecord::RecordNotUnique, ActiveRecord::RecordInvalid
    named(normalized) || raise
  end
end
