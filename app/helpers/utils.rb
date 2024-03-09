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

    if total.positive? && valid.positive? 
      if already_present == total 
        notice = "#{total == 1 ? 'Email is already present' : 'All Emails are already present'}"
      else
        notice = "Out of #{total} #{total == 1 ? 'Email' : 'Emails'} entered, #{valid} #{valid == 1 ? 'Email is' : 'Emails are'} valid. "
        notice += " #{invalid} #{invalid == 1 ? 'Email was' : 'Emails were'} invalid. " if invalid.positive?
        notice += "#{already_present} #{already_present == 1 ? 'Email was' : 'Emails were'} already present. " if already_present.positive?

        invited_emails_count = valid - already_present
        if invited_emails_count.positive?
          notice += " #{invited_emails_count} #{invited_emails_count == 1 ? 'Email is' : 'Emails are'} invited."
        end
      end
    else
      notice = "No valid Email(s) entered."
    end
    notice
  end
end