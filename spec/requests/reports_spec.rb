require 'rails_helper'

RSpec.describe "Reports", type: :request do
  describe "GET /new" do
    it "returns http success" do
      get "/reports/new"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /create" do
    it "returns http success" do
      get "/reports/create"
      expect(response).to have_http_status(:success)
    end
  end

end
