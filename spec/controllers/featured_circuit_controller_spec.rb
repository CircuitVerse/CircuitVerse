# frozen_string_literal: true

require "rails_helper"

describe FeaturedCircuitsController do
  before do
    @project = FactoryBot.create(:project, author: FactoryBot.create(:user),
                                           project_access_type: "Public")
  end

  describe "#index" do
    it "gets index page" do
      get featured_circuits_path
      expect(response).to have_http_status(:ok)
    end
  end

  context "user is not admin" do
    before do
      sign_in FactoryBot.create(:user)
    end

    it "does not authorize" do
      post featured_circuits_path, params: { featured: "1", project_id: @project.id }
      expect(response.body).to eq("You are not authorized to do the requested operation")
      delete featured_circuits_path, params: { featured: "0", project_id: @project.id }
      expect(response.body).to eq("You are not authorized to do the requested operation")
    end
  end

  context "user is admin" do
    before do
      sign_in FactoryBot.create(:user, admin: true)
    end

    it "creates featured_circuit" do
      expect do
        post featured_circuits_path, params: { featured_circuit:
          { featured: "1", project_id: @project.id } }
      end.to change(FeaturedCircuit, :count).by(1)
    end

    it "deletes featured_circuit" do
      FactoryBot.create(:featured_circuit, project: @project)

      expect do
        delete featured_circuits_path, params: { featured_circuit:
          { featured: "0", project_id: @project.id } }
      end.to change(FeaturedCircuit, :count).by(-1)
    end
  end
end
