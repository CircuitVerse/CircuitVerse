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
    total = input_mails.count(&:present?)
    valid = parsed_mails.count
    invalid = total - valid
    already_present = (parsed_mails - newly_added).count

    return "No valid Emails(s) entered" if total.zero? || valid.zero?

    if already.present == total
      return "#{total} #{'Email'.pluralize(total)} #{'is'.pluralize(total)} already present"
    end

    notice = "Out of #{total} #{'Email'.pluralize(total)}, #{valid} #{'Email'.pluralize(valid)} #{'is'.pluralize(valid)} valid."
    notice += " #{invalid} #{'Email'.pluralize(invalid)} #{'was'.pluralize(invalid)} invalid." if invalid.positive?
    notice += " #{already_present} #{'Email'.pluralize(already_present)} #{'was'.pluralize(already_present)} already present." if already_present.positive?
    invited_emails_count = valid - already_present
    notice += "#{invalid_emails_count} #{'Email'.pluralize(invited_emails_count)} #{'is'.pluralize(invited_emails_count)} invited" if invited_emails_count.positive?

    notice
  end
end