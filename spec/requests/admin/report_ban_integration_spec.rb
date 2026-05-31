# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Report Ban Integration", type: :request do
  let(:admin) { FactoryBot.create(:user, :admin, :confirmed) }
  let(:reporter) { FactoryBot.create(:user, :confirmed) }
  let(:reported_user) { FactoryBot.create(:user, :confirmed) }

  describe "complete report → ban → unban flow" do
    let!(:report) do
      Report.create!(
        reporter: reporter,
        reported_user: reported_user,
        reason: "Spam behavior",
        status: "open"
      )
    end

    before { sign_in admin }

    it "marks report as action_taken when user is banned" do
      expect(report.status).to eq("open")

      post ban_admin_user_path(reported_user), params: {
        reason: "Verified spam",
        report_id: report.id
      }

      expect(report.reload.status).to eq("action_taken")
      expect(reported_user.reload).to be_banned
    end

    it "links the ban to the report" do
      post ban_admin_user_path(reported_user), params: {
        reason: "Verified spam",
        report_id: report.id
      }

      ban = reported_user.user_bans.last
      expect(ban.report).to eq(report)
    end

    it "unbanning restores user access" do
      # First ban
      post ban_admin_user_path(reported_user), params: {
        reason: "Spam",
        report_id: report.id
      }
      expect(reported_user.reload).to be_banned

      # Then unban
      post unban_admin_user_path(reported_user)
      expect(reported_user.reload).not_to be_banned
    end

    it "banned user cannot authenticate" do
      post ban_admin_user_path(reported_user), params: { reason: "Banned" }

      expect(reported_user.reload.active_for_authentication?).to be false
      expect(reported_user.inactive_message).to eq(:banned)
    end
  end
end
