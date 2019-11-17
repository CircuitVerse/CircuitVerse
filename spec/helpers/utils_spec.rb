# frozen_string_literal: true

require "rails_helper"

describe Utils do
  before do
    @valid_email_count = 3
    @valid_emails = (1..@valid_email_count).reduce([]) { |e, _| e << Faker::Internet.email }
    @invalid_email_count = 3
    @invalid_emails = (1..@invalid_email_count).reduce([]) { |e, _| e << Faker::Internet.slug }
    @emails = @valid_emails + @invalid_emails
  end

  describe "#parse_mails" do
    it "parses email string to array" do
      expect(described_class.parse_mails(@emails.join(" "))).to eq(@valid_emails)
      expect(described_class.parse_mails(@emails.join(","))).to eq(@valid_emails)
      expect(described_class.parse_mails(@emails.join("\n"))).to eq(@valid_emails)
    end
  end

  describe "#mail_notice" do
    it "produces notice string" do
      notice = described_class.mail_notice(@emails.join(" "), @valid_emails, [ @valid_emails[0] ])
      expect(notice).to include("#{@valid_email_count} were valid")
      expect(notice).to include("#{@invalid_email_count} were invalid")
      expect(notice).to include("#{@invalid_email_count} were invalid")
      expect(notice).to include("1 user(s) will be invited")
    end
  end
end
