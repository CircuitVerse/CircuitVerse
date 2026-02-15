# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Reports", type: :request do
  describe "GET /reports/new" do
    it "redirects when user is not signed in" do
      get new_report_path
      expect(response).to have_http_status(:found) # 302
    end
  end

  describe "POST /reports" do
    it "redirects when user is not signed in" do
      post reports_path, params: { report: { reported_user_id: 1, reason: "Spam" } }
      expect(response).to have_http_status(:found) # 302
    end
  end
end
