# frozen_string_literal: true

class GroupMailer < ApplicationMailer
  def new_group_email(user, group)
    @mentor = user
    @user = @mentor
    @group = group
    return unless @mentor.subscribed?("circuitverse")

    mail(to: @mentor.email, subject: "New Group Created ")
  end

  def new_member_email(user, group)
    @user = user
    @group = group
    return unless @user.subscribed?("circuitverse")

    mail(to: @user.email, subject: "Added to a New group")
  end
end
