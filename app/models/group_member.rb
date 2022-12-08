# frozen_string_literal: true

class GroupMember < ApplicationRecord
  belongs_to :group, counter_cache: true
  belongs_to :user
  has_many :assignments, through: :group
  after_commit :send_welcome_notification
  after_commit :send_welcome_email, on: :create
  scope :mentor, -> { where(mentor: true) }
  scope :member, -> { where(mentor: false) }

  has_noticed_notifications model_name: "NoticedNotification", dependent: :destroy

  def send_welcome_notification
    group.group_members.each do |group_member|
      # Giving Multiple notifications to user added first
        NewGroupNotification.with(group: self).deliver_later(group_member.user)
    end
  end

  def send_welcome_email
    GroupMailer.new_member_email(user, group).deliver_later
  end
end
