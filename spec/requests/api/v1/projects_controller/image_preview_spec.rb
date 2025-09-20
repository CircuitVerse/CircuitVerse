# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V1::ProjectsController, "#image_preview", type: :request do
  describe "get project image preview" do
    let!(:public_project) { FactoryBot.create(:project, project_access_type: "Public") }
    let!(:private_project) { FactoryBot.create(:project) }

    context "when private project image_preview is requested" do
      before do
        get "/api/v1/projects/#{private_project.id}/image_preview", as: :json
      end

      it "returns status :not_found" do
        expect(response).to have_http_status(:not_found)
        expect(response.parsed_body).to have_jsonapi_errors
      end
    end

    context "when public project image_preview is requested" do
      before do
        get "/api/v1/projects/#{public_project.id}/image_preview", as: :json
      end

      it "returns image preview" do
        expect(response).to have_http_status(:ok)
      end
    end
  end
end
