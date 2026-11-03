# frozen_string_literal: true

class GroupMailer < ApplicationMailer
  def new_group_email(user, group)
    @mentor = user.is_a?(User) ? user : User.find_by(id: user)
    @group = group.is_a?(Group) ? group : Group.find_by(id: group)
    return unless @mentor && @group && !@mentor.opted_out?

    mail(to: [@mentor.email], subject: "New Group Created ")
  end

  def new_member_email(user, group)
    @user = user.is_a?(User) ? user : User.find_by(id: user)
    @group = group.is_a?(Group) ? group : Group.find_by(id: group)
    return unless @user && @group && !@user.opted_out?

    mail(to: [@user.email], subject: "Added to a New group")
  end
end
