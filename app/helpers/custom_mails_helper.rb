# frozen_string_literal: true

module CustomMailsHelper
  BATCH_SIZE = 1000

  def send_mail_in_batches(mail)
    User.subscribed.find_each(batch_size: BATCH_SIZE) do |user|
      UserMailer.custom_email(user, mail).deliver_later
    end
  end

  def send_mail_to_self(user, mail)
    UserMailer.custom_email(user, mail).deliver_later
  end
end
