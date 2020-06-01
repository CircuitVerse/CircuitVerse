# frozen_string_literal: true

class Group < ApplicationRecord
  validates :name, length: { minimum: 1 }
  belongs_to :mentor, class_name: "User"
  has_many :group_members, dependent: :destroy
  has_many :users, through: :group_members

  has_many :assignments, dependent: :destroy
  has_many :pending_invitations, dependent: :destroy

  after_commit :send_creation_mail, on: :create

  def send_creation_mail
    GroupMailer.new_group_email(mentor, self).deliver_later
  end
end
