# frozen_string_literal: true

class Group < ApplicationRecord
  has_secure_token :group_token
  has_secure_token :group_mentor_token
  validates :name, length: { minimum: 1 }, presence: true
  belongs_to :primary_mentor, class_name: "User"
  has_many :group_members, dependent: :destroy
  has_many :users, through: :group_members

  has_many :assignments, dependent: :destroy
  has_many :pending_invitations, dependent: :destroy

  after_commit :send_creation_mail, on: :create
  scope :with_valid_token, -> { where("token_expires_at >= ?", Time.zone.now) }
  scope :with_valid_mentor_token, -> { where("mentor_token_expires_at >= ?", Time.zone.now) }
  TOKEN_DURATION = 12.days

  def send_creation_mail
    GroupMailer.new_group_email(primary_mentor, self).deliver_later
  end

  def has_valid_token?
    token_expires_at.present? && token_expires_at > Time.zone.now
  end

  def has_valid_mentor_token?
    mentor_token_expires_at.present? && mentor_token_expires_at > Time.zone.now
  end

  def reset_group_token
    transaction do
      regenerate_group_token
      update(token_expires_at: Time.zone.now + TOKEN_DURATION)
    end
  end

  def reset_group_mentor_token
    transaction do
      regenerate_group_mentor_token
      update(mentor_token_expires_at: Time.zone.now + TOKEN_DURATION)
    end
  end
end
