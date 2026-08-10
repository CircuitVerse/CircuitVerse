# frozen_string_literal: true

class Organization < ApplicationRecord
  MAX_LINKS = 5
  extend FriendlyId

  friendly_id :name, use: :slugged

  has_many :organization_members, dependent: :destroy
  has_many :users, through: :organization_members
  has_many :groups, dependent: :nullify

  has_secure_token :invite_token

  INVITE_TOKEN_DURATION = 7.days

  scope :with_valid_invite_token, -> { where(invite_token_expires_at: Time.zone.now..) }

  def valid_invite_token?
    invite_token_expires_at.present? && invite_token_expires_at > Time.zone.now
  end

  def reset_invite_token(role:)
    regenerate_invite_token
    update!(invite_token_expires_at: Time.zone.now + INVITE_TOKEN_DURATION,
            invite_token_role: OrganizationMember.roles.fetch(role.to_s))
  end

  def add_member_from_invite(user)
    role = invite_token_role || OrganizationMember.roles[:member]
    organization_members.find_or_create_by!(user: user) do |member|
      member.role = role
    end
  end

  has_one_attached :logo
  attr_accessor :remove_logo

  before_validation { logo.purge if remove_logo == "1" }
  before_validation :sanitize_links

  validates :name, presence: true, uniqueness: { case_sensitive: false }, length: { minimum: 2, maximum: 50 }
  validates :slug, presence: true, uniqueness: { case_sensitive: false }
  validates :location, length: { maximum: 50 }, allow_blank: true
  validates :description, length: { maximum: 160 }, allow_blank: true
  validate :links_count_within_limit
  validate :links_must_be_valid_http_urls
  validate :logo_must_be_valid_image

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
      errors.add(:links, :invalid_urls) if invalid.any?
    end

    def links_count_within_limit
      return if links.blank?

      errors.add(:links, :too_many, count: MAX_LINKS) if links.size > MAX_LINKS
    end

    def logo_must_be_valid_image
      return unless logo.attached?

      acceptable_types = ["image/png", "image/jpeg", "image/svg+xml"]
      errors.add(:logo, :invalid_content_type) unless acceptable_types.include?(logo.content_type)

      errors.add(:logo, :file_size_exceeded) if logo.byte_size > 2.megabytes
    end
end
