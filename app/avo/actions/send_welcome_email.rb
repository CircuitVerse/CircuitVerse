# frozen_string_literal: true

class Avo::Actions::SendWelcomeEmail < Avo::BaseAction
  self.name = "Send Welcome Email"
  self.message = "Send welcome email to selected users?"
  self.confirm_button_label = "Send Email"
  self.cancel_button_label = "Cancel"

  def handle(query:, _fields:, _current_user:, _resource:, **_args)
    query.each do |user|
      UserMailer.welcome_email(user).deliver_later
    end

    succeed "Welcome email sent to #{query.count} user(s)"
  end
end
