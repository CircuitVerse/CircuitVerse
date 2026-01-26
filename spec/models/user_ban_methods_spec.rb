# frozen_string_literal: true

require "rails_helper"

RSpec.describe "User Ban Methods", type: :model do
  let(:admin) { FactoryBot.create(:user, :admin, :confirmed) }
  let(:regular_user) { FactoryBot.create(:user, :confirmed) }
  let(:another_admin) { FactoryBot.create(:user, :admin, :confirmed) }

  describe "associations" do
    it { expect(User.new).to have_many(:user_bans) }
    it { expect(User.new).to have_many(:imposed_bans).class_name("UserBan") }
  end

  describe "#banned?" do
    it "returns false for unbanned user" do
      expect(regular_user).not_to be_banned
    end

    it "returns true for banned user" do
      regular_user.update(banned: true)
      expect(regular_user).to be_banned
    end
  end

  describe "#ban!" do
    context "when banning a regular user" do
      it "creates a ban record" do
        expect do
          regular_user.ban!(admin: admin, reason: "Spam")
        end.to change(UserBan, :count).by(1)
      end

      it "sets banned to true" do
        regular_user.ban!(admin: admin, reason: "Spam")
        expect(regular_user.reload).to be_banned
      end

      it "returns true on success" do
        result = regular_user.ban!(admin: admin, reason: "Spam")
        expect(result).to be true
      end

      it "records the reason" do
        regular_user.ban!(admin: admin, reason: "Spam violation")
        expect(regular_user.user_bans.last.reason).to eq("Spam violation")
      end

      it "records the admin who performed the ban" do
        regular_user.ban!(admin: admin, reason: "Spam")
        expect(regular_user.user_bans.last.admin).to eq(admin)
      end
    end

    context "self-ban prevention" do
      it "prevents admin from banning themselves" do
        result = admin.ban!(admin: admin, reason: "Self ban attempt")
        expect(result).to be false
        expect(admin.reload).not_to be_banned
      end
    end

    context "admin-to-admin banning" do
      it "allows banning another admin" do
        result = another_admin.ban!(admin: admin, reason: "Admin violation")
        expect(result).to be true
        expect(another_admin.reload).to be_banned
      end
    end
  end

  describe "#unban!" do
    before do
      regular_user.ban!(admin: admin, reason: "Initial ban")
    end

    it "sets banned to false" do
      regular_user.unban!(admin: admin)
      expect(regular_user.reload).not_to be_banned
    end

    it "sets lifted_at on the ban record" do
      regular_user.unban!(admin: admin)
      expect(regular_user.user_bans.last.lifted_at).not_to be_nil
    end

    it "returns true on success" do
      result = regular_user.unban!(admin: admin)
      expect(result).to be true
    end
  end

  describe "#ban_history" do
    it "returns bans in descending order" do
      regular_user.ban!(admin: admin, reason: "First ban")
      regular_user.unban!(admin: admin)
      regular_user.ban!(admin: admin, reason: "Second ban")

      history = regular_user.ban_history
      expect(history.first.reason).to eq("Second ban")
    end
  end

  describe "#active_for_authentication?" do
    it "returns true for non-banned user" do
      expect(regular_user.active_for_authentication?).to be true
    end

    it "returns false for banned user" do
      regular_user.ban!(admin: admin, reason: "Banned")
      expect(regular_user.active_for_authentication?).to be false
    end
  end

  describe "#inactive_message" do
    it "returns :banned for banned user" do
      regular_user.ban!(admin: admin, reason: "Banned")
      expect(regular_user.inactive_message).to eq(:banned)
    end

    it "returns default for non-banned user" do
      expect(regular_user.inactive_message).not_to eq(:banned)
    end
  end
end
