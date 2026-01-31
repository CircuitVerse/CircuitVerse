# frozen_string_literal: true

require "rails_helper"

RSpec.describe UserBan, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:admin).class_name("User") }
    # Report association will be tested after Report model is implemented
    # it { is_expected.to belong_to(:report).optional }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:reason) }
    it { is_expected.to validate_presence_of(:user_id) }
    it { is_expected.to validate_presence_of(:admin_id) }
  end

  describe "scopes" do
    let!(:active_ban) { FactoryBot.create(:user_ban) }
    let!(:lifted_ban) { FactoryBot.create(:user_ban, :lifted) }

    describe ".active" do
      it "returns only active bans" do
        expect(described_class.active).to include(active_ban)
        expect(described_class.active).not_to include(lifted_ban)
      end
    end

    describe ".lifted" do
      it "returns only lifted bans" do
        expect(described_class.lifted).to include(lifted_ban)
        expect(described_class.lifted).not_to include(active_ban)
      end
    end
  end

  describe "#active?" do
    it "returns true when lifted_at is nil" do
      ban = FactoryBot.build(:user_ban, lifted_at: nil)
      expect(ban).to be_active
    end

    it "returns false when lifted_at is set" do
      ban = FactoryBot.build(:user_ban, lifted_at: Time.current)
      expect(ban).not_to be_active
    end
  end

  describe "#lift!" do
    let(:admin) { FactoryBot.create(:user, :admin) }
    let(:ban) { FactoryBot.create(:user_ban) }

    it "sets lifted_at to current time" do
      expect { ban.lift!(lifted_by: admin) }.to change(ban, :lifted_at).from(nil)
    end
  end
end
