# frozen_string_literal: true

class GroupMailer < ApplicationMailer
  def new_group_email(user, group)
    return if user.opted_out?

    @mentor = user
    @group = group
    mail(to: @mentor.email, subject: I18n.t("group_mailer.subject.new_group_created"))
  end

  def new_member_email(user, group)
    return if user.opted_out?

    @user = user
    @group = group
    mail(to: @user.email, subject: I18n.t("group_mailer.subject.add_to_new_group"))
  end
end
