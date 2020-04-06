# frozen_string_literal: true

require "rails_helper"

describe SearchController, type: :request do
  describe "#search" do
    context "search in a non-existant resource" do
      it "should return not found error" do
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

        it "should return results" do
          get search_path, params: { q: "Dummy", resource: "Users" }
          expect(response.status).to eq(200)
          expect(response.body).to include("Dummy User")
          expect(response.body).to include("Another Dummy User")
        end
      end

      context "search through educational institute" do
        before do
          FactoryBot.create(:user, name: "Dummy Techinical University")
          FactoryBot.create(:user, name: "Another Dummy Techinical University")
        end

        it "should return results" do
          get search_path, params: { q: "Techinical", resource: "Users" }
          expect(response.status).to eq(200)
          expect(response.body).to include("Dummy Techinical University")
          expect(response.body).to include("Another Dummy Techinical University")
        end
      end
    end

    context "Projects search" do
      context "searching through author" do
        before do
          author = FactoryBot.create(:user, name: "Dummy User")
          FactoryBot.create(:project, author: author, project_access_type: "Public",
            name: "Full adder using basic gates")
        end

        it "should return results" do
          get search_path, params: { q: "Dummy", resource: "Projects" }
          expect(response.status).to eq(200)
          expect(response.body).to include("Full adder using basic gates")
        end
      end

      context "search through tags" do
        before do
          project = FactoryBot.create(:project, name: "Full adder using half adder",
            project_access_type: "Public")
          project.tags << FactoryBot.create(:tag, name: "full_adder_using_half_adder")
        end

        it "should return results" do
          get search_path, params: { q: "full_adder", resource: "Projects" }
          expect(response.status).to eq(200)
          expect(response.body).to include("Full adder using half adder")
        end
      end

      context "searching through name" do
        it "should get some results" do
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
      end

      context "searching for a non-existant project" do
        it "should get no results" do
          FactoryBot.create(:project, name: "Full adder using basic gates",
            project_access_type: "Public")
          get search_path, params: { q: "half adder", resource: "Projects" }
          expect(response.status).to eq(200)
          expect(response.body).not_to include "Full adder using basic gates"
          expect(response.body).to include "No Results Found"
        end
      end
    end
  end
end
