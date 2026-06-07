# frozen_string_literal: true

class SubgroupMember < ApplicationRecord
  belongs_to :subgroup
  belongs_to :user

  enum :role, { member: 0, lead: 1 }, prefix: true

  validates :user_id, uniqueness: { scope: :subgroup_id }
  validate  :user_must_be_group_member

  private

  def user_must_be_group_member
    unless GroupMember.exists?(user_id: user_id,
                               group_id: subgroup.group_id)
      errors.add(:user, "must be a member of the parent group")
    end
  end
end
