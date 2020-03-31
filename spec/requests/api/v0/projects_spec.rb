# frozen_string_literal: true

require "rails-helper"

RSpec.describe Api::V0::ProjectsController do
  describe "GET #index" do
    it "should respond with error if Content-Type is not matching" do
      get "/api/v0/projects"
      expect(response.status).to eq(415)
    end

    it "should respond with error if Accept is not matching" do
      headers = {
        "CONTENT_TYPE": "application/vnd.api+json",
      }
      get "/api/v0/projects", headers: headers
      expect(response.status).to eq(406)
    end

    it "should respond with OK if Content-Type and Accept are matching" do
      headers = {
        "CONTENT_TYPE": "application/vnd.api+json",
        "ACCEPT": "application/vnd.api+json"
      }
      get "/api/v0/projects", headers: headers
      expect(response.status).to eq(200)
    end
  end
end
