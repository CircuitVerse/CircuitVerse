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
  before_validation :sanitize_links

  validates :name, presence: true, uniqueness: { case_sensitive: false }, length: { minimum: 2, maximum: 50 }
  validates :slug, presence: true, uniqueness: { case_sensitive: false }
  validates :location, length: { maximum: 100 }, allow_blank: true
  validate :links_count_within_limit
  validate :links_must_be_valid_http_urls

  before_destroy :purge_logo

  private

    def purge_logo
      logo.purge if logo.attached?
    end

    def sanitize_links
      return if links.blank?

      self.links = links.compact_blank.map(&:strip).map do |link|
        link.match?(/\A[a-z]+:/i) ? link : "https://#{link}"
      end
    end

    def links_must_be_valid_http_urls
      return if links.blank?

      invalid = links.reject do |link|
        uri = URI.parse(link.to_s)
        uri.is_a?(URI::HTTP) && uri.host.present?
      rescue URI::InvalidURIError
        false
      end
      errors.add(:links, "must be valid http or https URLs") if invalid.any?
    end

    def links_count_within_limit
      return if links.blank?

      errors.add(:links, "cannot have more than 5 links") if links.size > 5
    end
end
