# frozen_string_literal: true

require "rails_helper"

describe FeaturedCircuitsController, type: :request do
  before do
    @project = FactoryBot.create(:project, author: FactoryBot.create(:user), \
      project_access_type: "Public")
  end

  describe "#index" do
    it "should get index page" do
      get featured_circuits_path
      expect(response.status).to eq(200)
    end
  end

  context "user is not admin" do
    before do
      sign_in FactoryBot.create(:user)
    end

    it "should not authorize" do
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
      expect {
        post featured_circuits_path, params: { featured_circuit: \
          { featured: "1", project_id: @project.id } }
      }.to change { FeaturedCircuit.count }.by(1)
    end

    it "deletes featured_circuit" do
      FactoryBot.create(:featured_circuit, project: @project)

      expect {
        delete featured_circuits_path, params: { featured_circuit: \
          { featured: "0", project_id: @project.id } }
      }.to change { FeaturedCircuit.count }.by(-1)
    end
  end
end
