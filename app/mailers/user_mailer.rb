# frozen_string_literal: true

class UserMailer < ApplicationMailer
  def custom_email(user, mail)
    return if user.opted_out?

    @user = user
    @mail = mail
    mail(to: user.email, subject: mail.subject)
  end

  def welcome_email(user)
    @user = user
    @url = "CircuitVerse.org"
    mail(to: @user.email, subject: I18n.t("user_mailer.subject.signup_confirmation"))
  end

  def new_project_email(user, project)
    return if user.opted_out?

    @user = user
    @project = project
    mail(to: @user.email, subject: I18n.t("user_mailer.subject.new_project_created"))
  end

  def forked_project_email(user, old_project, new_project)
    return if user.opted_out?

    @user = user
    @old_project = old_project
    @new_project = new_project
    mail(to: @user.email, subject: I18n.t("user_mailer.subject.new_project_created"))
  end

  def featured_circuit_email(user, project)
    return if user.opted_out?

    @user = user
    @project = project
    mail(to: @user.email, subject: I18n.t("user_mailer.subject.project_featured"))
  end
end
