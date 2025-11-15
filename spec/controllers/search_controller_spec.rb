# frozen_string_literal: true

require "rails_helper"

describe SearchController, type: :request do
  describe "#search" do
    context "search in a non-existant resource" do
      it "returns not found error" do
        get search_path, params: { q: "Dummy query", resource: "NonExistantResource" }
        expect(response.body).to include("OOPS,THE PAGE YOU ARE LOOKING FOR CAN'T BE FOUND!")
      end
    end

    context "Users search" do
      context "search through name" do
        before do
          FactoryBot.create(:user, name: "Dummy User")
          FactoryBot.create(:user, name: "Another Dummy User")
        end

        it "returns results" do
          get search_path, params: { q: "Dummy", resource: "Users" }
          expect(response.status).to eq(200)
          expect(response.body).to include("Dummy User")
          expect(response.body).to include("Another Dummy User")
        end

        it "returns JSON results without template error" do
          get search_path, params: { q: "Dummy", resource: "Users", format: :json }
          expect(response.status).to eq(200)
          expect(response.content_type).to include("application/json")
          json_response = JSON.parse(response.body)
          expect(json_response).to be_an(Array)
          expect(json_response.length).to eq(2)
        end

        it "includes correct user attributes in JSON response" do
          get search_path, params: { q: "Dummy", resource: "Users", format: :json }
          expect(response.status).to eq(200)
          json_response = JSON.parse(response.body)
          first_user = json_response.first
          expect(first_user).to have_key("id")
          expect(first_user).to have_key("name")
          expect(first_user).to have_key("url")
          expect(first_user["name"]).to match(/Dummy User/)
        end
      end

      context "search through educational institute" do
        before do
          FactoryBot.create(:user, name: "Dummy Techinical University")
          FactoryBot.create(:user, name: "Another Dummy Techinical University")
        end

        it "returns results" do
          get search_path, params: { q: "Techinical", resource: "Users" }
          expect(response.status).to eq(200)
          expect(response.body).to include("Dummy Techinical University")
          expect(response.body).to include("Another Dummy Techinical University")
        end
      end
    end

    context "Projects search" do
      context "search through tags" do
        before do
          project = FactoryBot.create(:project, name: "Full adder using half adder",
                                                project_access_type: "Public")
          project.tags << FactoryBot.create(:tag, name: "full_adder_using_half_adder")
        end

        it "returns results" do
          get search_path, params: { q: "full_adder", resource: "Projects" }
          expect(response.status).to eq(200)
          expect(response.body).to include("Full adder using half adder")
        end

        it "returns JSON results without template error" do
          get search_path, params: { q: "full_adder", resource: "Projects", format: :json }
          expect(response.status).to eq(200)
          expect(response.content_type).to include("application/json")
          json_response = JSON.parse(response.body)
          expect(json_response).to be_an(Array)
          expect(json_response.length).to eq(1)
          expect(json_response.first["name"]).to eq("Full adder using half adder")
        end

        it "includes correct project attributes in JSON response" do
          get search_path, params: { q: "full_adder", resource: "Projects", format: :json }
          expect(response.status).to eq(200)
          json_response = JSON.parse(response.body)
          first_project = json_response.first
          expect(first_project).to have_key("id")
          expect(first_project).to have_key("name")
          expect(first_project).to have_key("author_id")
          expect(first_project).to have_key("project_access_type")
          expect(first_project).to have_key("views")
          expect(first_project).to have_key("stars")
          expect(first_project).to have_key("url")
          expect(first_project).to have_key("created_at")
          expect(first_project).to have_key("updated_at")
        end
      end

      context "searching through name" do
        it "gets some results" do
          FactoryBot.create(:project, name: "Full adder using basic gates",
                                      project_access_type: "Public")
          FactoryBot.create(:project, name: "Half adder using basic gates",
                                      project_access_type: "Public")
          FactoryBot.create(:project, name: "Full adder using half adder",
                                      project_access_type: "Public")
          get search_path, params: { q: "basic gates", resource: "Projects" }
          expect(response.status).to eq(200)
          expect(response.body).to include "Full adder using basic gates"
          expect(response.body).to include "Half adder using basic gates"
          expect(response.body).not_to include "Full adder using half adder"
        end

        it "returns correct JSON results for name search" do
          FactoryBot.create(:project, name: "Full adder using basic gates",
                                      project_access_type: "Public")
          FactoryBot.create(:project, name: "Half adder using basic gates",
                                      project_access_type: "Public")
          FactoryBot.create(:project, name: "Full adder using half adder",
                                      project_access_type: "Public")
          get search_path, params: { q: "basic gates", resource: "Projects", format: :json }
          expect(response.status).to eq(200)
          expect(response.content_type).to include("application/json")
          json_response = JSON.parse(response.body)
          expect(json_response).to be_an(Array)
          expect(json_response.length).to eq(2)
          project_names = json_response.map { |p| p["name"] }
          expect(project_names).to include("Full adder using basic gates")
          expect(project_names).to include("Half adder using basic gates")
          expect(project_names).not_to include("Full adder using half adder")
        end
      end

      context "searching for a non-existant project" do
        it "gets no results" do
          FactoryBot.create(:project, name: "Full adder using basic gates",
                                      project_access_type: "Public")
          get search_path, params: { q: "half adder", resource: "Projects" }
          expect(response.status).to eq(200)
          expect(response.body).not_to include "Full adder using basic gates"
          expect(response.body).to include "No Results Found"
        end

        it "returns empty JSON array for no results" do
          FactoryBot.create(:project, name: "Full adder using basic gates",
                                      project_access_type: "Public")
          get search_path, params: { q: "half adder", resource: "Projects", format: :json }
          expect(response.status).to eq(200)
          expect(response.content_type).to include("application/json")
          json_response = JSON.parse(response.body)
          expect(json_response).to be_an(Array)
          expect(json_response).to be_empty
        end
      end
    end
  end
end
