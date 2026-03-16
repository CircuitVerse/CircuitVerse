# frozen_string_literal: true

class Group < ApplicationRecord
  has_secure_token :group_token
  validates :name, length: { minimum: 1 }, presence: true
  validates :allowed_domain,
            format: { with: /\A[a-zA-Z0-9]([a-zA-Z0-9\-]*\.)+[a-zA-Z]{2,}\z/,
                      allow_blank: true,
                      message: "must be a valid domain (e.g., example.com)" }

  belongs_to :primary_mentor, class_name: "User"
  has_many :group_members, dependent: :destroy
  has_many :users, through: :group_members
  has_many :assignments, dependent: :destroy
  has_many :pending_invitations, dependent: :destroy
  has_many :subgroups, dependent: :destroy

  # Multi-level hierarchy
  belongs_to :parent_group, class_name: "Group", optional: true
  has_many   :child_groups, class_name: "Group",
             foreign_key: :parent_group_id, dependent: :destroy

  after_commit :send_creation_mail, on: :create
  scope :with_valid_token, -> { where(token_expires_at: Time.zone.now..) }
  TOKEN_DURATION = 12.days

  validate :no_circular_reference
  validate :max_depth_three

  def root?
    parent_group_id.nil?
  end

  def ancestors
    return [] if root?
    [parent_group] + parent_group.ancestors
  end

  def depth
    ancestors.length
  end

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
    email_domain == allowed_domain
  end

  private

    def extract_domain(email)
      return nil if email.blank?
      email_parts = email.split("@")
      email_parts.length > 1 ? email_parts[1].downcase : nil
    end

    def no_circular_reference
      return unless persisted?
      return unless parent_group_id.present?
      if parent_group_id == id || ancestors.map(&:id).include?(id)
        errors.add(:parent_group, "cannot create circular reference")
      end
    end

    def max_depth_three
      return unless parent_group_id.present?
      if depth >= 3
        errors.add(:parent_group, "maximum nesting depth is 3 levels")
      end
    end
end
