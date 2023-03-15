# frozen_string_literal: true

module MailerHelper
  def mail_if_subscribed(recipient_email, subject, user)
    return unless user.subscribed?("circuitverse")

    mail(to: recipient_email, subject: subject)
  end
end
