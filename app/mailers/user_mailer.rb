# frozen_string_literal: true

class UserMailer < ApplicationMailer
  def custom_email(user, mail)
    @user = user.is_a?(User) ? user : User.find_by(id: user)
    @mail = mail.is_a?(CustomMail) ? mail : CustomMail.find_by(id: mail)
    return unless @user && @mail && !@user.opted_out?

    mail(to: [@user.email], subject: @mail.subject)
  end

  def welcome_email(user)
    @user = user.is_a?(User) ? user : User.find_by(id: user)
    return unless @user

    @url = "CircuitVerse.org"
    mail(to: [@user.email], subject: "Signing up Confirmation")
  end

  def new_project_email(user, project)
    @user = user.is_a?(User) ? user : User.find_by(id: user)
    @project = project.is_a?(Project) ? project : Project.find_by(id: project)
    return unless @user && @project && !@user.opted_out?

    mail(to: [@user.email], subject: "New Project Created")
  end

  def forked_project_email(user, old_project, new_project)
    @user = user.is_a?(User) ? user : User.find_by(id: user)
    @old_project = old_project.is_a?(Project) ? old_project : Project.find_by(id: old_project)
    @new_project = new_project.is_a?(Project) ? new_project : Project.find_by(id: new_project)
    return unless @user && @old_project && @new_project && !@user.opted_out?

    mail(to: [@user.email], subject: "New Project Created")
  end

  def featured_circuit_email(user, project)
    @user = user.is_a?(User) ? user : User.find_by(id: user)
    @project = project.is_a?(Project) ? project : Project.find_by(id: project)
    return unless @user && @project && !@user.opted_out?

    mail(to: [@user.email], subject: "Your project is now featured!")
  end
end
