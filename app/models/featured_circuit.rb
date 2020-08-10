# frozen_string_literal: true

class FeaturedCircuit < ApplicationRecord
  belongs_to :project

  after_create :featured_circuit_email, :send_featured_circuit_notif
  validate :project_public

  private

    def project_public
      return unless project.project_access_type != "Public"

      errors.add(:project, "Featured projects have to be public")
    end

    def featured_circuit_email
      UserMailer.featured_circuit_email(project.author, project).deliver_later
    end

    def send_featured_circuit_notif
      return if project.author.fcm.nil?

      FcmNotification.send(
        project.author.fcm.token,
        "Project Featured",
        "Your project #{project.name} is now featured"
      )
    end
end
