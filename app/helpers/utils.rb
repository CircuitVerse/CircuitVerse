# frozen_string_literal: true

module Utils
  # Filters out all the valid emails from the argument string
  # @param [String] mails string of emails entered
  # @return [Array<String>] array of valid emails
  def self.parse_mails(mails)
    mails.split(/[\s,]/).select do |email|
      email.present? && Devise.email_regexp.match?(email)
    end.uniq.map(&:downcase)
  end

  # Filters out all the valid emails from the argument string except the current user's email
  # @param [String] mails string of emails entered
  # @param [User] current current user
  # @return [Array<String>] array of valid emails
  def self.parse_mails_except_current_user(mails, current)
    mails.split(/[\s,]/).select do |email|
      email.present? && email != current.email && Devise.email_regexp.match?(email)
    end.uniq.map(&:downcase)
  end

  # Forms notice string for given email input
  # @param [Array<String>] input_mails string of emails entered
  # @param [Array<String>] parsed_mails array of valid emails
  # @param [Array<String>] newly_added array of emails that have been newly added
  # @return [String] notice string
  def self.mail_notice(input_mails, parsed_mails, newly_added)
    total_emails = input_mails.count(&:present?)
    valid_emails = parsed_mails.count
    invalid_emails = total_emails - valid_emails
    already_present_count = (parsed_mails - newly_added).count

    if total_emails.positive? && valid_emails.positive?
      "Out of #{total_emails} Email(s), #{valid_emails} #{valid_emails == 1 ? 'was' : 'were'} \
valid and #{invalid_emails} #{invalid_emails == 1 ? 'was' : 'were'} invalid. \
#{newly_added.count} user(s) will be invited. " +
        (if already_present_count.zero?
           "No users were already present."
         else
           "#{already_present_count} user(s) #{already_present_count == 1 ? 'was' : 'were'} already present."
         end)
    else
      "No valid Email(s) entered."
    end
  end
end
