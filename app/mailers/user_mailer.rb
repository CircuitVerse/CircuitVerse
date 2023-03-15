# frozen_string_literal: true

class UserMailer < ApplicationMailer
  def custom_email(user, mail)
    @user = user
    @mail = mail
    mail_if_subscribed(user.email, mail.subject, user)
  end

  def welcome_email(user)
    @user = user
    @url = "CircuitVerse.org"
    mail(to: @user.email, subject: "Signing up Confirmation")
  end

  def new_project_email(user, project)
    @user = user
    @project = project
    mail_if_subscribed(@user.email, "New Project Created", user)
  end

  def forked_project_email(user, old_project, new_project)
    @user = user
    @old_project = old_project
    @new_project = new_project
    mail_if_subscribed(@user.email, "New Project Created", user)
  end

  def featured_circuit_email(user, project)
    @user = user
    @project = project
    mail_if_subscribed(@user.email, "Your project is now featured!", user)
  end
end
