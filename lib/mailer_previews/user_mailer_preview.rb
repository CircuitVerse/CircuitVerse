# frozen_string_literal: true

class UserMailerPreview < ActionMailer::Preview
  def new_project_email
    UserMailer.new_project_email(User.first, Project.first)
  end

  def featured_circuit_email
    UserMailer.featured_circuit_email(User.first, Project.first)
  end
end
