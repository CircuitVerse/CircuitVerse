# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V1::ProjectsController, "#search", type: :request do
  describe "project search pagination" do
    before do
      @author = FactoryBot.create(:user)
      FactoryBot.create(:project, author: @author, name: "Adder circuit")
    end

    context "when pagination parameters are omitted" do
      it "returns the first page instead of raising" do
        get "/api/v1/projects/search", params: { q: "adder" }, as: :json

        expect(response).to have_http_status(:ok)
        expect(response.parsed_body["data"]).to be_an(Array)
      end
    end

    context "when pagination parameters are given" do
      it "returns the requested page" do
        get "/api/v1/projects/search", params: { q: "adder", page: { number: 1 } }, as: :json

        expect(response).to have_http_status(:ok)
      end
    end

    context "when page is a scalar rather than an object" do
      it "ignores it instead of raising" do
        get "/api/v1/projects/search", params: { q: "adder", page: 2 }, as: :json

        expect(response).to have_http_status(:ok)
      end
    end
  end
end
