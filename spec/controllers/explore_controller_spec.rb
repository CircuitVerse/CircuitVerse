# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExploreController, type: :controller do
  describe "GET #index" do
    context "when feature flag is disabled" do
      before do
        Flipper.disable(:circuit_explore_page)
      end

      it "redirects to root path" do
        get :index

        expect(response).to redirect_to(root_path)
      end
    end

    context "when feature flag is enabled" do
      before do
        Flipper.enable(:circuit_explore_page)
      end

      it "returns http success" do
        get :index

        expect(response).to have_http_status(:ok)
      end

      context "when section param is 'examples'" do
        it "redirects to picks section" do
          get :index, params: { section: "examples" }

          expect(response).to redirect_to(explore_path(section: "picks"))
        end
      end
    end
  end
end
