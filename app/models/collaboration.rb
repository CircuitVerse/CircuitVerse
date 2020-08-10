# frozen_string_literal: true

class Collaboration < ApplicationRecord
  belongs_to :user
  belongs_to :project

  after_create :send_new_collaboration_notif

  def send_new_collaboration_notif
    return if user.fcm.nil?

    FcmNotification.send(
      user.fcm.token,
      "Added as Collaborator",
      "#{project.author.name} added you as a collaborator in #{project.name}"
    )
  end
end
