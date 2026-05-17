# frozen_string_literal: true

class Group < ApplicationRecord
  VALID_DOMAIN_REGEX = /\A(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z]{2,}\z/i

  has_secure_token :group_token
  before_validation :normalize_allowed_domain

  validates :name, length: { minimum: 1 }, presence: true
  validates :allowed_domain,
            format: { with: VALID_DOMAIN_REGEX, allow_blank: true,
                      message: :invalid_domain }
  belongs_to :primary_mentor, class_name: "User"
  has_many :group_members, dependent: :destroy
  has_many :users, through: :group_members

  has_many :assignments, dependent: :destroy
  has_many :pending_invitations, dependent: :destroy

  after_commit :send_creation_mail, on: :create
  scope :with_valid_token, -> { where(token_expires_at: Time.zone.now..) }
  TOKEN_DURATION = 12.days

  def send_creation_mail
    GroupMailer.new_group_email(primary_mentor, self).deliver_later
  end

  def has_valid_token?
    token_expires_at.present? && token_expires_at > Time.zone.now
  end

  def reset_group_token
    transaction do
      regenerate_group_token
      update(token_expires_at: Time.zone.now + TOKEN_DURATION)
    end
  end

  def can_join?(email)
    return true if allowed_domain.blank?

    email_domain = extract_domain(email)
    email_domain&.downcase == allowed_domain
  end

  private

    def extract_domain(email)
      return nil if email.blank?

      email_parts = email.split("@")
      email_parts.length > 1 ? email_parts[1].downcase : nil
    end

    def normalize_allowed_domain
      self.allowed_domain = allowed_domain.to_s.strip.downcase.presence
    end
end
