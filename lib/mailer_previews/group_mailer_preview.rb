# frozen_string_literal: true

class GroupMailerPreview < ActionMailer::Preview
  def new_group_email
    GroupMailer.new_group_email(User.first, Group.first)
  end

  def new_member_email
    GroupMailer.new_member_email(User.first, Group.first)
  end
end
