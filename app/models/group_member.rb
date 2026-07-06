# frozen_string_literal: true

class GroupMember < ApplicationRecord
  belongs_to :group, counter_cache: true
  belongs_to :user
  has_many :assignments, through: :group

  # Mirrors the unique DB index so duplicates fail validation instead of
  # raising PG::UniqueViolation.
  validates :user_id, uniqueness: { scope: :group_id }
  validate :user_must_belong_to_parent_group, if: -> { group&.subgroup? }

  after_commit :send_welcome_email, on: :create, unless: -> { group.subgroup? }
  scope :mentor, -> { where(mentor: true) }
  scope :member, -> { where(mentor: false) }

  def send_welcome_email
    GroupMailer.new_member_email(user, group).deliver_later
  end

  private

    # Subgroups partition an existing class: only users already in the parent
    # group (or its primary mentor) can be placed in a subgroup.
    def user_must_belong_to_parent_group
      parent = group.parent_group
      return if parent.blank?
      return if parent.primary_mentor_id == user_id
      return if parent.group_members.exists?(user_id: user_id)

      errors.add(:user, "must be a member of the parent group")
    end
end
