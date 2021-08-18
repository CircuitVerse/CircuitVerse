# frozen_string_literal: true

module Utils
  # Filters out all the valid emails from the argument string
  # @param mails string of emails entered
  # @return array of valid emails
  def self.parse_mails(mails)
    mails.split(/[\s,]/).select do |email|
      email.present? && Devise.email_regexp.match?(email)
    end.uniq.map(&:downcase)
  end

  def self.parse_mails_except_current_user(mails, current)
    mails.split(/[\s,]/).select do |email|
      email.present? && email != current.email && Devise.email_regexp.match?(email)
    end.uniq.map(&:downcase)
  end

  # Forms notice string for given email input
  # @param input_mails string of emails entered
  # @param parsed_mails array of valid emails
  # @param newly_added array of emails that have been newly added
  # @return notice string
  def self.mail_notice(input_mails, parsed_mails, newly_added)
    total = input_mails.split(/[\s,]/).count(&:present?)
    valid = parsed_mails.count
    invalid = total - valid
    already_present = (parsed_mails - newly_added).count
    was = I18n.t("helpers.utils.was")
    were = I18n.t("helpers.utils.were")

    notice = if total != 0 && valid != 0
      I18n.t("helpers.utils.email_send_status", total: total, valid: valid, was_or_were_valid: valid == 1 ? was : were, invalid: invalid,  was_or_were_invalid: invalid == 1 ? 'was' : 'were', newly_added_count: newly_added.count) + \
        (if already_present.zero?
           I18n.t("helpers.utils.no_already_present_users")
         else
           I18n.t("helpers.utils.users_already_present", already_present: already_present, was_or_were: already_present == 1 ? was : were)
         end)
    else
      I18n.t("helpers.utils.no_valid_emails_entered")
    end
  end
end
