# frozen_string_literal: true
require "rails_helper"

RSpec.describe "Explore", type: :request do
  context "flag disabled" do
    it "404s (route not available)" do
      get "/explore"
      expect(response.status).to eq(404)
    end
  end

  context "flag enabled" do
    before { flipper_enable(:circuit_explore_page) }

    it "renders explore page" do
      get "/explore"
      expect(response.status).to eq(200)
      expect(response.body).to include(I18n.t("explore.cotw.heading"))
      expect(response.body).to include(I18n.t("explore.editor_picks.heading"))
    end
  end
end
