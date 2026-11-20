# frozen_string_literal: true

class GroupMember < ApplicationRecord
  belongs_to :group, counter_cache: true
  belongs_to :user
  has_many :assignments, through: :group

  validates :user_id, uniqueness: { scope: :group_id }

  after_commit :send_welcome_email, on: :create, unless: -> { group.subgroup? }
  scope :mentor, -> { where(mentor: true) }
  scope :member, -> { where(mentor: false) }

  def send_welcome_email
    GroupMailer.new_member_email(user, group).deliver_later
  end
end
