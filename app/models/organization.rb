# frozen_string_literal: true

class Organization < ApplicationRecord
  extend FriendlyId

  friendly_id :name, use: :slugged

  has_many :organization_members, dependent: :destroy
  has_many :users, through: :organization_members
  has_many :groups, dependent: :nullify

  has_one_attached :logo
  attr_accessor :remove_logo

  before_validation { logo.purge if remove_logo == "1" }

  validates :name, presence: true, uniqueness: { case_sensitive: false }
  validates :slug, presence: true, uniqueness: { case_sensitive: false }
  validates :location, length: { maximum: 100 }, allow_blank: true
  validate :links_count_within_limit

  before_destroy :purge_logo

  private

    def purge_logo
      logo.purge if logo.attached?
    end

    def links_count_within_limit
      return if links.blank?

      errors.add(:links, "cannot have more than 5 links") if links.size > 5
    end
end
