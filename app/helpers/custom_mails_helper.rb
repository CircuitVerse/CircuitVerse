# frozen_string_literal: true

module CustomMailsHelper
  BATCH_SIZE = 1000

  def send_mail_in_batches(mail)
    mail_id = mail.is_a?(CustomMail) ? mail.id : mail
    User.subscribed.in_batches(of: BATCH_SIZE) do |batch|
      batch.pluck(:id).each do |user_id|
        UserMailer.custom_email(user_id, mail_id).deliver_later
      end
    end
  end

  def send_mail_to_self(user, mail)
    user_id = user.is_a?(User) ? user.id : user
    mail_id = mail.is_a?(CustomMail) ? mail.id : mail
    UserMailer.custom_email(user_id, mail_id).deliver_later
  end
end
