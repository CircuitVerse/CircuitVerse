# frozen_string_literal: true

class Group < ApplicationRecord
  validates :name, length: { minimum: 1 }
  belongs_to :owner, class_name: "User"
  has_many :group_members, dependent: :destroy
  has_many :group_mentors, dependent: :destroy
  has_many :members, through: :group_members, source: :user
  has_many :mentors, through: :group_mentors, source: :user

  has_many :assignments, dependent: :destroy
  has_many :pending_invitations, dependent: :destroy

  after_commit :send_creation_mail, on: :create

  def send_creation_mail
    GroupMailer.new_group_email(owner, self).deliver_later
  end
end
