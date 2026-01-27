# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Admin::Reports", type: :request do
  let(:admin) { FactoryBot.create(:user, :admin, :confirmed) }
  let(:regular_user) { FactoryBot.create(:user, :confirmed) }

  describe "GET /admins/reports" do
    context "when not logged in" do
      it "redirects to login" do
        get admin_reports_path
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "when logged in as non-admin" do
      before { sign_in regular_user }

      it "redirects to root with access denied" do
        get admin_reports_path
        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to include("Access denied")
      end
    end

    context "when logged in as admin" do
      before { sign_in admin }

      it "returns success" do
        get admin_reports_path
        expect(response).to have_http_status(:success)
      end

      it "renders the index template" do
        get admin_reports_path
        expect(response.body).to include("User Reports")
      end

      # NOTE: Full report functionality tests will be added when Report model is implemented
    end
  end
end
