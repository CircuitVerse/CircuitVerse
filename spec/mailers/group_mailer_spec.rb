# frozen_string_literal: true

require "rails_helper"

RSpec.describe GroupMailer, type: :mailer do
  before do
    @primary_mentor = create(:user)
    @group = create(:group, primary_mentor: @primary_mentor)
  end

  describe "new_group_email" do
    let(:mail) { described_class.new_group_email(@primary_mentor, @group) }

    it "sends new group email" do
      expect(mail.to).to eq([@primary_mentor.email])
      expect(mail.subject).to eq("New Group Created ")
    end
  end

  describe "new_member_email" do
    before do
      @user = create(:user)
    end

    let(:mail) { described_class.new_member_email(@user, @group) }

    it "sends new member email" do
      expect(mail.to).to eq([@user.email])
      expect(mail.subject).to eq("Added to a New group")
    end
  end
end
