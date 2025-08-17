# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Explore", type: :request do
  context "flag disabled" do
    it "redirects to root when disabled" do
      get "/explore"
      expect(response).to have_http_status(:found)
      expect(response).to redirect_to(root_path)
    end
  end

  context "flag enabled" do
    before { flipper_enable(:circuit_explore_page) }

    it "renders explore page" do
      get "/explore"
      expect(response.status).to eq(200)
      expect(response.body).to include(I18n.t("explore.sections.cotw.heading"))
      expect(response.body).to include(I18n.t("explore.sections.picks.heading"))
    end
  end
end
