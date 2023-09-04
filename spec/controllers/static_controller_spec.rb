# frozen_string_literal: true

# spec/controllers/static_controller_spec.rb

require "rails_helper"

RSpec.describe StaticController, type: :controller do
  describe "#simulatorvue" do
    it "renders the simulatorvue template" do
      get :simulatorvue, params: { path: "/" }

      expect(response).to have_http_status(:success)
      expect(response.body).to include(File.read(Rails.public_path.join("simulatorvue", "index.html")))
    end
  end
end
