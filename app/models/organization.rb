# frozen_string_literal: true

class Organization < ApplicationRecord
  has_many :organization_members, dependent: :destroy
  has_many :users, through: :organization_members
  has_many :groups, dependent: :nullify

  has_one_attached :logo

  validates :name, presence: true, uniqueness: { case_sensitive: false }
  validates :slug, presence: true, uniqueness: { case_sensitive: false }
  validate :links_count_within_limit

  private

    def links_count_within_limit
      errors.add(:links, "cannot have more than 5 links") if links.size > 5
    end
end