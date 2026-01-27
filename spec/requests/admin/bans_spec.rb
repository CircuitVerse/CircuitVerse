# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Admin::Bans", type: :request do
  let(:admin) { FactoryBot.create(:user, :admin, :confirmed) }
  let(:regular_user) { FactoryBot.create(:user, :confirmed) }
  let(:another_admin) { FactoryBot.create(:user, :admin, :confirmed) }

  describe "POST /admins/users/:id/ban" do
    context "when not logged in" do
      it "redirects to login" do
        post ban_admin_user_path(regular_user), params: { reason: "Spam" }
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "when logged in as non-admin" do
      before { sign_in regular_user }

      it "redirects to root with access denied" do
        another_user = FactoryBot.create(:user, :confirmed)
        post ban_admin_user_path(another_user), params: { reason: "Spam" }
        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to include("Access denied")
      end
    end

    context "when logged in as admin" do
      before { sign_in admin }

      it "bans the user successfully" do
        post ban_admin_user_path(regular_user), params: { reason: "Repeated spam" }
        expect(regular_user.reload).to be_banned
      end

      it "redirects with success message" do
        post ban_admin_user_path(regular_user), params: { reason: "Spam" }
        expect(response).to redirect_to(admin_reports_path)
        expect(flash[:notice]).to be_present
      end

      it "requires a reason" do
        post ban_admin_user_path(regular_user), params: { reason: "" }
        expect(regular_user.reload).not_to be_banned
        expect(flash[:alert]).to include("required")
      end

      it "prevents self-ban" do
        post ban_admin_user_path(admin), params: { reason: "Self ban" }
        expect(admin.reload).not_to be_banned
        expect(flash[:alert]).to be_present
      end

      it "allows banning another admin" do
        post ban_admin_user_path(another_admin), params: { reason: "Admin violation" }
        expect(another_admin.reload).to be_banned
      end

      it "closes ALL open reports for the banned user" do
        # Create multiple reports for the same user
        reporter = FactoryBot.create(:user, :confirmed)
        report1 = Report.create!(reporter: reporter, reported_user: regular_user, reason: "Spam", status: "open")
        report2 = Report.create!(reporter: reporter, reported_user: regular_user, reason: "Harassment", status: "open")
        report3 = Report.create!(reporter: reporter, reported_user: regular_user, reason: "Other", status: "dismissed")

        post ban_admin_user_path(regular_user), params: { reason: "Multiple violations", report_id: report1.id }

        expect(report1.reload.status).to eq("action_taken")
        expect(report2.reload.status).to eq("action_taken")
        expect(report3.reload.status).to eq("dismissed") # Not changed since already dismissed
      end
    end
  end

  describe "POST /admins/users/:id/unban" do
    before do
      regular_user.ban!(admin: admin, reason: "Initial ban")
    end

    context "when not logged in" do
      it "redirects to login" do
        post unban_admin_user_path(regular_user)
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "when logged in as admin" do
      before { sign_in admin }

      it "unbans the user successfully" do
        post unban_admin_user_path(regular_user)
        expect(regular_user.reload).not_to be_banned
      end

      it "redirects with success message" do
        post unban_admin_user_path(regular_user)
        expect(response).to redirect_to(admin_reports_path)
        expect(flash[:notice]).to include("unbanned")
      end
    end
  end
end
