# frozen_string_literal: true

class GroupMember < ApplicationRecord
  belongs_to :group, counter_cache: true
  belongs_to :user
  has_many :assignments, through: :group
  after_commit :send_welcome_notification, on: :create
  after_commit :send_welcome_email, on: :create
  scope :mentor, -> { where(mentor: true) }
  scope :member, -> { where(mentor: false) }

  has_noticed_notifications param_name: :group, model_name: "NoticedNotification", dependent: :destroy

  def send_welcome_notification
    NewGroupNotification.with(group: self).deliver_later(user)
  end

  def send_welcome_email
    GroupMailer.new_member_email(user, group).deliver_later
  end
end
