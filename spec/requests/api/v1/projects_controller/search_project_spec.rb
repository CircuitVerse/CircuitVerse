# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V1::ProjectsController, "#search" do
  describe "list projects based on query" do
    before do
      # Generate public projects
      project_names = ["Full adder using basic gates", "Half adder using basic gates",
                       "Full adder using half adder"]

      project_names.each do |name|
        create(:project, name: name, project_access_type: "Public")
      end
    end

    context "when query is empty" do
      before do
        get "/api/v1/projects/search?q=&page[number]=1", as: :json
      end

      it "returns projects list" do
        expect(response).to have_http_status(:ok)
        expect(response).to match_response_schema("projects")
        expect(response.parsed_body["data"].length).to eq(3)
      end
    end

    context "when query is not empty" do
      before do
        get "/api/v1/projects/search?q=full&page[number]=1", as: :json
      end

      it "returns projects list" do
        expect(response).to have_http_status(:ok)
        expect(response).to match_response_schema("projects")
        expect(response.body).not_to include "Half adder using basic gates"
        expect(response.parsed_body["data"].length).to eq(2)
      end
    end

    context "when query does not match any project" do
      before do
        get "/api/v1/projects/search?q=random&page[number]=1", as: :json
      end

      it "returns projects list" do
        expect(response).to have_http_status(:ok)
        expect(response.parsed_body["data"].length).to eq(0)
      end
    end
  end
end
