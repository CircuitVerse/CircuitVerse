# frozen_string_literal: true

require "rails_helper"

describe ErrorsController, type: :request do
  describe "#not_found" do
    it "should return 404" do
      get "/404"
      expect(response.body).to include("We can't seem to find the page you're looking for :(")
      expect(response.body).to include("Error code: 404")
    end
  end

  describe "#not_found" do
    it "should return 404" do
      get "/500"
      expect(response.body).to include("Server Errored!")
      expect(response.body).to include("Error code: 500")
    end
  end

  describe "#not_found" do
    it "should return 404" do
      get "/422"
      expect(response.body).to include("Request could not be processed :(")
      expect(response.body).to include("Error code: 422")
    end
  end
end
