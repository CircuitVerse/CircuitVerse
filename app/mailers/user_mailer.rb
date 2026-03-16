# frozen_string_literal: true

class UserMailer < ApplicationMailer
  def custom_email(user, mail)
    return if user.opted_out?

    @user = user
    @mail = mail
    mail(to: [user.email], subject: mail.subject)
  end

  def welcome_email(user)
    @user = user
    @url = "CircuitVerse.org"
    mail(to: [@user.email], subject: "Signing up Confirmation")
  end

  def new_project_email(user, project)
    return if user.opted_out?

    @user = user
    @project = project
    mail(to: [@user.email], subject: "New Project Created")
  end

  def forked_project_email(user, old_project, new_project)
    return if user.opted_out?

    @user = user
    @old_project = old_project
    @new_project = new_project
    mail(to: [@user.email], subject: "New Project Created")
  end

  def featured_circuit_email(user, project)
    return if user.opted_out?

    @user = user
    @project = project
    mail(to: [@user.email], subject: "Your project is now featured!")
  end

def group_invitation_email(email, group)
  @group = group
  @join_url = invite_group_url(group, token: group.group_token)
  mail(to: email, subject: "You've been invited to join #{group.name} on CircuitVerse")
end
end
