# frozen_string_literal: true

require "rails_helper"

RSpec.describe GroupMailer, type: :mailer do
  before do
    @owner = FactoryBot.create(:user)
    @group = FactoryBot.create(:group, owner: @owner)
  end

  describe "new_group_email" do
    let(:mail) { described_class.new_group_email(@owner, @group) }

    it "sends new group email" do
      expect(mail.to).to eq([@owner.email])
      expect(mail.subject).to eq("New Group Created ")
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
  end
end
