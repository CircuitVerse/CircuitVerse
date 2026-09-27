# frozen_string_literal: true

require "rails_helper"

describe Utils do
  before do
    @valid_email_count = 3
    @valid_emails = (1..@valid_email_count).reduce([]) { |e, _| e << Faker::Internet.email }
    @invalid_email_count = 3
    @invalid_emails = (1..@invalid_email_count).reduce([]) { |e, _| e << Faker::Internet.slug }
    @emails = @valid_emails + @invalid_emails
    @emails = @emails.to_a
  end

  describe "#parse_mails" do
    it "parses email string to array" do
      expect(described_class.parse_mails(@emails.join(" "))).to eq(@valid_emails)
      expect(described_class.parse_mails(@emails.join(","))).to eq(@valid_emails)
      expect(described_class.parse_mails(@emails.join("\n"))).to eq(@valid_emails)
    end

    it "parses email string to array except current user's mail" do
      current_user = create(:user)
      valid_emails = @valid_emails + [current_user.email]
      expect(described_class.parse_mails_except_current_user(valid_emails.join(" "), current_user)).to eq(@valid_emails)
    end

    it "removes emails that differ only in case" do
      emails = "Jane@Example.com jane@example.com JANE@EXAMPLE.COM"
      expect(described_class.parse_mails(emails)).to eq(["jane@example.com"])
    end

    it "excludes the current user's mail regardless of case" do
      current_user = create(:user)
      emails = [@valid_emails.first, current_user.email.upcase].join(",")
      parsed = described_class.parse_mails_except_current_user(emails, current_user)
      expect(parsed).to eq([@valid_emails.first.downcase])
    end
  end

  describe "#mail_notice" do
    it "produces notice string" do
      notice = described_class.mail_notice(@emails, @valid_emails, [@valid_emails[0]])
      expect(notice).to include("#{@valid_email_count} were valid")
      expect(notice).to include("#{@invalid_email_count} were invalid")
      expect(notice).to include("1 user(s) will be invited")
    end

    it "produces notice string with no valid emails" do
      notice = described_class.mail_notice([], [], [])
      expect(notice).to include("No valid Email(s) entered.")
    end
  end
end
