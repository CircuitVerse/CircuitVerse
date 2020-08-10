# frozen_string_literal: true

class GroupMember < ApplicationRecord
  belongs_to :group, counter_cache: true
  belongs_to :user
  has_many :assignments, through: :group

  after_create :send_welcome_email, :send_new_member_notif
  after_destroy :send_remove_member_notif

  def send_welcome_email
    GroupMailer.new_member_email(user, group).deliver_later
  end

  def send_new_member_notif
    return if user.fcm.nil?

    FcmNotification.send(
      user.fcm.token,
      "Added to Group",
      "You have been added to #{group.name}"
    )
  end

  def send_remove_member_notif
    return if user.fcm.nil?

    FcmNotification.send(
      user.fcm.token,
      "Removed from Group",
      "You have been removed from #{group.name}"
    )
  end
end
