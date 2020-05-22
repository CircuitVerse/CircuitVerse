# frozen_string_literal: true

module Utils
  # Filters out all the valid emails from the argument string
  # @param mails string of emails entered
  # @return array of valid emails
  def self.parse_mails(mails)
    mails.split(/[\s,\,]/).select do |email|
      email.present? && Devise.email_regexp.match?(email)
    end.uniq.map(&:downcase)
  end

  def self.parse_mails_except_current_user(mails, current)
    mails.split(/[\s,\,]/).select do |email|
      email.present? && email != current.email && Devise.email_regexp.match?(email)
    end.uniq.map(&:downcase)
  end

  # Forms notice string for given email input
  # @param input_mails string of emails entered
  # @param parsed_mails array of valid emails
  # @param newly_added array of emails that have been newly added
  # @return notice string
  def self.mail_notice(input_mails, parsed_mails, newly_added)
    total = input_mails.split(/[\s,\,]/).count(&:present?)
    valid = parsed_mails.count
    invalid = total - valid
    already_present = (parsed_mails - newly_added).count

    notice = if total != 0 && valid != 0
      "Out of #{total} Email(s), #{valid} #{valid != 1 ? 'were' : 'was'} valid and #{invalid} #{invalid != 1 ? 'were' : 'was'} invalid. #{newly_added.count} user(s) will be invited. " + \
        (already_present == 0 ? "No users were already present." : "#{already_present} user(s) #{already_present != 1 ? 'were' : 'was'} already present.")
    else
      "No valid Email(s) entered."
    end
  end
end
