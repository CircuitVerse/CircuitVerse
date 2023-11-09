# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V1::AuthenticationController, "#public_key", type: :request do
  describe "GET public key" do
    it "returns the public key" do
      get "/api/v1/public_key.pem"
      expect(response).to have_http_status(:ok)
    end
  end
end
