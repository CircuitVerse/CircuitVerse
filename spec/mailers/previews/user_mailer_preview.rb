class UserMailerPreview < ActionMailer::Preview
  def group_invitation_email
    group = Group.first
    UserMailer.group_invitation_email("test@sjec.ac.in", group)
  end
end
