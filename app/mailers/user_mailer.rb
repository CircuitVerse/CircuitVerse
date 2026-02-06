# frozen_string_literal: true

class UserMailer < ApplicationMailer
  def custom_email(user, mail)
    return if user.opted_out? || !valid_email?(user.email)

    @user = user
    @mail = mail
    mail(to: [user.email], subject: mail.subject)
  end

  def welcome_email(user)
    return unless valid_email?(user.email)

    @user = user
    @url = "CircuitVerse.org"
    mail(to: [@user.email], subject: "Signing up Confirmation")
  end

  def new_project_email(user, project)
    return if user.opted_out? || !valid_email?(user.email)

    @user = user
    @project = project
    mail(to: [@user.email], subject: "New Project Created")
  end

  def forked_project_email(user, old_project, new_project)
    return if user.opted_out? || !valid_email?(user.email)

    @user = user
    @old_project = old_project
    @new_project = new_project
    mail(to: [@user.email], subject: "New Project Created")
  end

  def featured_circuit_email(user, project)
    return if user.opted_out? || !valid_email?(user.email)

    @user = user
    @project = project
    mail(to: [@user.email], subject: "Your project is now featured!")
  end

  private

  def valid_email?(email)
    email.present? && email.include?("@")
  end
end
