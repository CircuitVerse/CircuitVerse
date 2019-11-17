# frozen_string_literal: true

require "rails_helper"

RSpec.describe GroupMailer, type: :mailer do
  before do
    @mentor = FactoryBot.create(:user)
    @group = FactoryBot.create(:group, mentor: @mentor)
  end

  describe "new_group_email" do
    let(:mail) { GroupMailer.new_group_email(@mentor, @group) }

    it "sends new group email" do
      expect(mail.to).to eq([@mentor.email])
      expect(mail.subject).to eq("New Group Created ")
    end
  end

  describe "new_member_email" do
    before do
      @user = FactoryBot.create(:user)
    end

    let(:mail) { GroupMailer.new_member_email(@user, @group) }

    it "sends new member email" do
      expect(mail.to).to eq([@user.email])
      expect(mail.subject).to eq("Added to a New group")
    end
  end
end
