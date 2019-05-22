# frozen_string_literal: true

class UserMailer < ApplicationMailer
  def welcome_email(user)
    @user = user
    @url = "CircuitVerse.org"
    mail(to: @user.email, subject: "Signing up Confirmation")
  end

  def new_project_email(user, project)
    @user = user
    @project = project
    mail(to: @user.email, subject: "New Project Created")
  end

  def forked_project_email(user, old_project, new_project)
    @user = user
    @old_project = old_project
    @new_project = new_project
    mail(to: @user.email, subject: "New Project Created")
  end

  def featured_circuit_email(user, project)
    @user = user
    @project = project
    mail(to: @user.email, subject: "You project is now featured!")
  end
end
