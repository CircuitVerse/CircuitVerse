# frozen_string_literal: true

class UserMailer < ApplicationMailer

  # @param [User] user
  # @param [CustomMail] mail
  # @return [void]
  def custom_email(user, mail)
    return if user.opted_out?

    @user = user
    @mail = mail
    mail(to: user.email, subject: mail.subject)
  end

  # @param [User] user
  # @return [void]
  def welcome_email(user)
    @user = user
    @url = "CircuitVerse.org"
    mail(to: @user.email, subject: "Signing up Confirmation")
  end

  # @param [User] user
  # @param [Project] project
  # @return [void]
  def new_project_email(user, project)
    return if user.opted_out?

    @user = user
    @project = project
    mail(to: @user.email, subject: "New Project Created")
  end

  # @param [User] user
  # @param [Project] old_project
  # @param [Project] new_project
  # @return [void]  
  def forked_project_email(user, old_project, new_project)
    return if user.opted_out?

    @user = user
    @old_project = old_project
    @new_project = new_project
    mail(to: @user.email, subject: "New Project Created")
  end

  # @param [User] user
  # @param [Project] project
  # @return [void]
  def featured_circuit_email(user, project)
    return if user.opted_out?

    @user = user
    @project = project
    mail(to: @user.email, subject: "Your project is now featured!")
  end
end
