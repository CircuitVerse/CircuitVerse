# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Admin::Dashboards", type: :request do
  let(:admin) { create(:user, :admin) }

  before do
    sign_in admin
  end

  describe "GET /index" do
    it "redirects to dashboard" do
      get "/admin2"
      expect(response).to have_http_status(:redirect)
      follow_redirect!
      expect(response).to have_http_status(:success)
      expect(response.body).to include("Avo")
    end
  end
end
