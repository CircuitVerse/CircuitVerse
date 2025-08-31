# frozen_string_literal: true

require "rails_helper"

describe ErrorsController, type: :controller do
  render_views

  describe "#not_found" do
    it "returns 404" do
      get :not_found
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "#internal_error" do
    it "returns 500" do
      get :internal_error
      expect(response).to have_http_status(:internal_server_error)
    end
  end

  describe "#unacceptable" do
    it "returns 422" do
      get :unacceptable
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end
end
