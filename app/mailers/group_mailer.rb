# frozen_string_literal: true

class GroupMailer < ApplicationMailer
  def new_group_email(user, group)
    @mentor = user
    @user = @mentor
    @group = group
    mail_if_subscribed(@mentor.email, "New Group Created ", user)
  end

  def new_member_email(user, group)
    @user = user
    @group = group
    mail_if_subscribed(@user.email, "Added to a New group", user)
  end
end
