# frozen_string_literal: true

class UserMailerPreview < ActionMailer::Preview
  def new_project_email
    UserMailer.new_project_email(User.first, Project.first)
  end

  def featured_circuit_email
    UserMailer.featured_circuit_email(User.first, Project.first)
  end

  def custom_email
    mail = CustomMail.new(subject: "Launching Graded Assignments!",
      content: "<i> Now grade your assignments with CircuitVerse! </i>")
    UserMailer.custom_email(User.first, mail)
  end
end
