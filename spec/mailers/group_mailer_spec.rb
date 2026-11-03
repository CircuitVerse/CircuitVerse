# frozen_string_literal: true

require "rails_helper"

RSpec.describe GroupMailer, type: :mailer do
  before do
    @primary_mentor = FactoryBot.create(:user)
    @group = FactoryBot.create(:group, primary_mentor: @primary_mentor)
  end

  describe "new_group_email" do
    let(:mail) { described_class.new_group_email(@primary_mentor, @group) }

    it "sends new group email" do
      expect(mail.to).to eq([@primary_mentor.email])
      expect(mail.subject).to eq("New Group Created ")
    end

    it "supports scalar IDs as arguments" do
      mail_from_ids = described_class.new_group_email(@primary_mentor.id, @group.id)
      expect(mail_from_ids.to).to eq([@primary_mentor.email])
      expect(mail_from_ids.subject).to eq("New Group Created ")
    end

    it "handles missing/deleted records gracefully" do
      expect(described_class.new_group_email(999_999, @group.id).message).to be_a(ActionMailer::Base::NullMail)
      expect(described_class.new_group_email(@primary_mentor.id, 999_999).message).to be_a(ActionMailer::Base::NullMail)
    end

    it "does not deliver if user opted out" do
      allow(@primary_mentor).to receive(:opted_out?).and_return(true)
      expect(described_class.new_group_email(@primary_mentor, @group).message).to be_a(ActionMailer::Base::NullMail)
    end
  end

  describe "new_member_email" do
    before do
      @user = FactoryBot.create(:user)
    end

    let(:mail) { described_class.new_member_email(@user, @group) }

    it "sends new member email" do
      expect(mail.to).to eq([@user.email])
      expect(mail.subject).to eq("Added to a New group")
    end

    it "supports scalar IDs as arguments" do
      mail_from_ids = described_class.new_member_email(@user.id, @group.id)
      expect(mail_from_ids.to).to eq([@user.email])
      expect(mail_from_ids.subject).to eq("Added to a New group")
    end

    it "handles missing/deleted records gracefully" do
      expect(described_class.new_member_email(999_999, @group.id).message).to be_a(ActionMailer::Base::NullMail)
      expect(described_class.new_member_email(@user.id, 999_999).message).to be_a(ActionMailer::Base::NullMail)
    end

    it "does not deliver if user opted out" do
      allow(@user).to receive(:opted_out?).and_return(true)
      expect(described_class.new_member_email(@user, @group).message).to be_a(ActionMailer::Base::NullMail)
    end
  end
end
