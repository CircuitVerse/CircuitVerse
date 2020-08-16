# frozen_string_literal: true

require "rails_helper"

RSpec.describe Fcm, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:user) }
  end

  describe "validations" do
    let(:user) { FactoryBot.create(:user) }

    context "when token is null" do
      let(:fcm) { FactoryBot.build(:fcm, token: nil, user: user) }

      it "invalidates fcm" do
        expect(fcm).to be_invalid
      end
    end

    context "when token is empty string" do
      let(:fcm) { FactoryBot.build(:fcm, token: "", user: user) }

      it "invalidates fcm" do
        expect(fcm).to be_invalid
      end
    end

    context "when user_id is not unique" do
      let(:fcm) { FactoryBot.create(:fcm, token: "token", user: user) }

      it "validates uniqueness of :user_id in fcm" do
        expect(fcm).to validate_uniqueness_of(:user_id)
      end
    end
  end
end
