# frozen_string_literal: true

# spec/controllers/static_controller_spec.rb

require "rails_helper"

RSpec.describe StaticController, type: :controller do
  describe "#simulatorvue" do
    it "renders the simulatorvue template with default version" do
      get :simulatorvue, params: { path: "/" }

      expect(response).to have_http_status(:success)
      expect(response.body).to include(Rails.public_path.join("simulatorvue", "v0", "index-cv.html").read)
    end

    it "renders the simulatorvue template with specified version" do
      version = "v1"
      get :simulatorvue, params: { simver: version }

      expect(response).to have_http_status(:success)
      expect(response.body).to include(Rails.public_path.join("simulatorvue", version, "index-cv.html").read)
    end
  end
end