# frozen_string_literal: true

#
# == Schema Information
#
# Table name: groups
#
#  id                    :bigint           not null, primary key
#  name                  :string
#  primary_mentor_id     :bigint
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  group_members_count   :integer
#  group_token           :string
#  token_expires_at      :datetime
#
# Indexes
#
#  index_groups_on_primary_mentor_id  (primary_mentor_id)
#  index_groups_on_group_token        (group_token) UNIQUE

class Group < ApplicationRecord
  has_secure_token :group_token
  validates :name, length: { minimum: 1 }, presence: true
  belongs_to :primary_mentor, class_name: "User"
  has_many :group_members, dependent: :destroy
  has_many :users, through: :group_members

  has_many :assignments, dependent: :destroy
  has_many :pending_invitations, dependent: :destroy

  after_commit :send_creation_mail, on: :create
  scope :with_valid_token, -> { where("token_expires_at >= ?", Time.zone.now) }
  TOKEN_DURATION = 12.days

  def send_creation_mail
    GroupMailer.new_group_email(primary_mentor, self).deliver_later
  end

  # @return [Boolean] Return true if the token is valid
  def has_valid_token?
    token_expires_at.present? && token_expires_at > Time.zone.now
  end

  # @return [void]
  def reset_group_token
    transaction do
      regenerate_group_token
      update(token_expires_at: Time.zone.now + TOKEN_DURATION)
    end
  end
end
