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
    total_emails = input_mails.count(&:present?)
    valid_emails = parsed_mails.count

    # Calculate invalid emails using ternary operator for brevity
    invalid_emails = total_emails > valid_emails ? total_emails - valid_emails : 0

    # Use string interpolation for cleaner formatting
    message = "Out of #{total_emails} email(s), #{valid_emails} " \
              "#{valid_emails == 1 ? 'was' : 'were'} valid and " \
              "#{invalid_emails} #{invalid_emails == 1 ? 'was' : 'were'} invalid."

    already_present_users = (parsed_mails - newly_added).count
    unless already_present_users.zero?
      message << " #{already_present_users} user(s) " \
                 "#{already_present_users == 1 ? 'was' : 'were'} already present."
    end

    message
  end
end
