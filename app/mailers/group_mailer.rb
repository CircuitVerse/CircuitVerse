# frozen_string_literal: true

class GroupMailer < ApplicationMailer
  # @param [User] user
  # @param [Group] group
  # @return [void]
  def new_group_email(user, group)
    return if user.opted_out?

    @mentor = user
    @group = group
    mail(to: @mentor.email, subject: "New Group Created ")
  end

  # @param [User] user
  # @param [Group] group
  # @return [void]
  def new_member_email(user, group)
    return if user.opted_out?

    @user = user
    @group = group
    mail(to: @user.email, subject: "Added to a New group")
  end
end
