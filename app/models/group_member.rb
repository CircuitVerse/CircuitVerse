# frozen_string_literal: true

#
# == Schema Information
#
# Table name: group_members
#
#  id         :bigint           not null, primary key
#  group_id   :bigint
#  user_id    :bigint
#  mentor     :boolean          default(FALSE)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_group_members_on_group_id  (group_id)
#  index_group_members_on_user_id   (user_id)
#  index_group_members_on_group_id_and_user_id  (group_id,user_id) UNIQUE
#

class GroupMember < ApplicationRecord
  belongs_to :group, counter_cache: true
  belongs_to :user
  has_many :assignments, through: :group

  after_commit :send_welcome_email, on: :create
  scope :mentor, -> { where(mentor: true) }
  scope :member, -> { where(mentor: false) }

  def send_welcome_email
    GroupMailer.new_member_email(user, group).deliver_later
  end
end
