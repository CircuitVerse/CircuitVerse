# frozen_string_literal: true

class GroupMember < ApplicationRecord
  belongs_to :group
  belongs_to :user
  has_many :assignments, through: :group

  after_commit :send_welcome_email, on: :create

  def send_welcome_email
    GroupMailer.new_member_email(user, group).deliver_later
  end
end
